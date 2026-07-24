<#
.SYNOPSIS
    INC-001 - Obtiene los eventos 4740 (bloqueo de cuenta) desde el PDC Emulator.

.DESCRIPTION
    Consulta el log de Seguridad del PDC Emulator para identificar el origen
    (Caller Computer Name) de los intentos fallidos que causaron un bloqueo.
    Soporta consulta de un usuario concreto (TASK-02) o de todo el dominio (TASK-03,
    para detectar patrones de ataque como password spraying).

.PARAMETER Usuario
    sAMAccountName del usuario a investigar. Si se omite, se usa -Todos.

.PARAMETER Todos
    Devuelve los eventos 4740 de TODOS los usuarios en el rango de horas indicado.
    Útil para TASK-03 al evaluar si el patrón es sospechoso a nivel de dominio.

.PARAMETER Horas
    Ventana de búsqueda hacia atrás, en horas. Por defecto 24.

.PARAMETER ExportarCSV
    Ruta opcional donde exportar el resultado como evidencia para el ticket.

.EXAMPLE
    .\obtener_eventos.ps1 -Usuario jperez -Horas 24

.EXAMPLE
    .\obtener_eventos.ps1 -Todos -Horas 1 -ExportarCSV "C:\Evidencias\INC-001_patron.csv"

.NOTES
    Requiere permisos de lectura sobre el log de Seguridad del PDC Emulator
    (grupo Event Log Readers o delegación equivalente).
    Cuándo ejecutarlo: TASK-02 (origen de un bloqueo concreto) y TASK-03
    (evaluación de patrón sospechoso a nivel de dominio).
#>

[CmdletBinding(DefaultParameterSetName = 'PorUsuario')]
param(
    [Parameter(ParameterSetName = 'PorUsuario')]
    [string]$Usuario,

    [Parameter(ParameterSetName = 'Todos')]
    [switch]$Todos,

    [int]$Horas = 24,

    [string]$ExportarCSV
)

$ErrorActionPreference = 'Stop'

if (-not $Usuario -and -not $Todos) {
    Write-Error "Debes especificar -Usuario <sAMAccountName> o -Todos"
    exit 1
}

try {
    Import-Module ActiveDirectory -ErrorAction Stop
    $pdc = (Get-ADDomain).PDCEmulator
    Write-Host "Consultando log de Seguridad en PDC Emulator: $pdc (ultimas $Horas horas)" -ForegroundColor Cyan

    $filtro = @{
        LogName   = 'Security'
        Id        = 4740
        StartTime = (Get-Date).AddHours(-$Horas)
    }

    $eventos = Get-WinEvent -ComputerName $pdc -FilterHashtable $filtro -ErrorAction Stop

    if ($Usuario) {
        $eventos = $eventos | Where-Object { $_.Properties[0].Value -eq $Usuario }
    }

    if (-not $eventos) {
        Write-Host "No se encontraron eventos 4740 en el rango solicitado." -ForegroundColor Yellow
        exit 0
    }

    $resultado = $eventos | Select-Object TimeCreated,
        @{N = 'UsuarioBloqueado'; E = { $_.Properties[0].Value } },
        @{N = 'CallerComputer'; E = { $_.Properties[1].Value } }

    Write-Host "`nEventos encontrados: $($resultado.Count)`n" -ForegroundColor Yellow
    $resultado | Sort-Object TimeCreated -Descending | Format-Table -AutoSize

    # Aviso de patron sospechoso: mismo origen afectando a varios usuarios distintos
    $origenesMultiUsuario = $resultado | Group-Object CallerComputer |
        Where-Object { ($_.Group.UsuarioBloqueado | Select-Object -Unique).Count -gt 1 }

    if ($origenesMultiUsuario) {
        Write-Host "`n[AVISO] Los siguientes origenes han generado bloqueos en MAS DE UN usuario distinto:" -ForegroundColor Red
        $origenesMultiUsuario | ForEach-Object {
            Write-Host " - $($_.Name): $((($_.Group.UsuarioBloqueado) | Select-Object -Unique) -join ', ')" -ForegroundColor Red
        }
        Write-Host "Ver TASK-03 del Playbook: esto cumple un criterio de escalado a INC-002." -ForegroundColor Red
    }

    if ($ExportarCSV) {
        $resultado | Export-Csv -Path $ExportarCSV -NoTypeInformation -Encoding UTF8
        Write-Host "`nEvidencia exportada a: $ExportarCSV" -ForegroundColor Cyan
    }
}
catch [System.Diagnostics.Eventing.Reader.EventLogNotFoundException] {
    Write-Error "No se encontraron eventos 4740 en el log de Seguridad del PDC en el rango indicado."
    exit 0
}
catch {
    Write-Error "Error al consultar eventos: $($_.Exception.Message)"
    exit 1
}
