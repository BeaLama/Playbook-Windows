<#
.SYNOPSIS
    INC-002 - Busca sign-ins recientes de un usuario en Entra ID y resalta anomalias.

.DESCRIPTION
    Consulta el log de inicios de sesion de Microsoft Entra ID via Microsoft Graph
    y marca visualmente los resultados con nivel de riesgo (RiskLevelDuringSignIn)
    o paises distintos en ventanas de tiempo cortas (posible "impossible travel").
    Usado en TASK-001 (corroboracion inicial) y TASK-006 (seguimiento post-recuperacion).

.PARAMETER UserPrincipalName
    UPN del usuario a investigar (obligatorio).

.PARAMETER Horas
    Ventana de busqueda hacia atras, en horas. Por defecto 72.

.PARAMETER ExportarCSV
    Ruta opcional donde exportar el resultado como evidencia.

.EXAMPLE
    .\Buscar-SignInsSospechosos.ps1 -UserPrincipalName usuario@empresa.com -Horas 72

.NOTES
    Requiere el modulo Microsoft.Graph y permisos AuditLog.Read.All, User.Read.All.
    Conectar previamente con: Connect-MgGraph -Scopes "AuditLog.Read.All","User.Read.All"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [int]$Horas = 72,

    [string]$ExportarCSV
)

$ErrorActionPreference = 'Stop'

function Write-ColorLine {
    param([string]$Texto, [string]$Color = 'White')
    Write-Host $Texto -ForegroundColor $Color
}

try {
    if (-not (Get-MgContext)) {
        Write-Error "No hay sesion activa de Microsoft Graph. Ejecuta: Connect-MgGraph -Scopes 'AuditLog.Read.All','User.Read.All'"
        exit 1
    }

    $desde = (Get-Date).AddHours(-$Horas).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $filtro = "userPrincipalName eq '$UserPrincipalName' and createdDateTime ge $desde"

    Write-ColorLine "Consultando sign-ins de '$UserPrincipalName' desde $desde ..." "Cyan"

    $signIns = Get-MgAuditLogSignIn -Filter $filtro -Top 100 -ErrorAction Stop |
        Sort-Object CreatedDateTime -Descending

    if (-not $signIns) {
        Write-ColorLine "No se encontraron sign-ins en la ventana solicitada." "Yellow"
        exit 0
    }

    $resultado = $signIns | Select-Object `
        CreatedDateTime,
        IpAddress,
        @{N = 'Ciudad'; E = { $_.Location.City } },
        @{N = 'Pais'; E = { $_.Location.CountryOrRegion } },
        @{N = 'Dispositivo'; E = { $_.DeviceDetail.DisplayName } },
        @{N = 'SO'; E = { $_.DeviceDetail.OperatingSystem } },
        @{N = 'CodigoError'; E = { $_.Status.ErrorCode } },
        RiskLevelDuringSignIn,
        RiskState

    Write-Host ""
    $resultado | Format-Table -AutoSize

    # Deteccion simple de "impossible travel": paises distintos en menos de 2 horas
    $paisesOrdenados = $resultado | Sort-Object CreatedDateTime
    for ($i = 1; $i -lt $paisesOrdenados.Count; $i++) {
        $actual = $paisesOrdenados[$i]
        $anterior = $paisesOrdenados[$i - 1]
        if ($actual.Pais -and $anterior.Pais -and $actual.Pais -ne $anterior.Pais) {
            $diferenciaHoras = (New-TimeSpan -Start $anterior.CreatedDateTime -End $actual.CreatedDateTime).TotalHours
            if ($diferenciaHoras -lt 2 -and $diferenciaHoras -ge 0) {
                Write-ColorLine "[AVISO] Posible 'impossible travel': $($anterior.Pais) -> $($actual.Pais) en $([math]::Round($diferenciaHoras,2)) horas" "Red"
            }
        }
    }

    $riesgoAlto = $resultado | Where-Object { $_.RiskLevelDuringSignIn -in @('high', 'medium') -or $_.RiskState -eq 'confirmedCompromised' }
    if ($riesgoAlto) {
        Write-ColorLine "`n[AVISO] Sign-ins marcados con riesgo por Identity Protection:" "Red"
        $riesgoAlto | Format-Table CreatedDateTime, IpAddress, Pais, RiskLevelDuringSignIn, RiskState -AutoSize
    }

    if ($ExportarCSV) {
        $resultado | Export-Csv -Path $ExportarCSV -NoTypeInformation -Encoding UTF8
        Write-ColorLine "`nEvidencia exportada a: $ExportarCSV" "Cyan"
    }
}
catch {
    Write-Error "Error al consultar sign-ins: $($_.Exception.Message)"
    exit 1
}
