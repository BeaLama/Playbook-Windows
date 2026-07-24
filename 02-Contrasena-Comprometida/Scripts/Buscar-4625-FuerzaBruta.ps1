<#
.SYNOPSIS
    INC-002 - Detecta patrones de fuerza bruta / password spraying en AD on-premises
    a partir de eventos 4625 (fallo de inicio de sesion).

.DESCRIPTION
    Complementa a Buscar-SignInsSospechosos.ps1 (que cubre Entra ID) para entornos
    hibridos o puramente on-premises. Agrupa los eventos 4625 por origen (direccion
    IP / nombre de estacion) y por cuenta objetivo, y resalta:
      - Un mismo origen fallando contra MUCHAS cuentas distintas (password spraying).
      - Un mismo origen fallando MUCHAS veces contra UNA cuenta (fuerza bruta dirigida).

.PARAMETER Usuario
    sAMAccountName de un usuario concreto a investigar. Si se omite, se analiza
    todo el dominio (recomendado para deteccion de password spraying).

.PARAMETER Horas
    Ventana de busqueda hacia atras, en horas. Por defecto 6 (los ataques de
    spraying suelen ser rafagas cortas).

.PARAMETER UmbralCuentasDistintas
    Numero minimo de cuentas distintas afectadas por el mismo origen para
    considerarlo password spraying. Por defecto 3.

.PARAMETER ExportarCSV
    Ruta opcional donde exportar el resultado como evidencia.

.EXAMPLE
    .\Buscar-4625-FuerzaBruta.ps1 -Horas 6

.EXAMPLE
    .\Buscar-4625-FuerzaBruta.ps1 -Usuario jperez -Horas 24

.NOTES
    Debe ejecutarse contra el/los Domain Controllers, o de forma remota con
    permisos de lectura sobre el log de Seguridad (grupo Event Log Readers).
#>

[CmdletBinding()]
param(
    [string]$Usuario,

    [int]$Horas = 6,

    [int]$UmbralCuentasDistintas = 3,

    [string]$ExportarCSV
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
    $dcs = (Get-ADDomainController -Filter *).HostName

    Write-Host "Consultando eventos 4625 en $($dcs.Count) Domain Controller(s), ultimas $Horas horas..." -ForegroundColor Cyan

    $filtro = @{
        LogName   = 'Security'
        Id        = 4625
        StartTime = (Get-Date).AddHours(-$Horas)
    }

    $todosLosEventos = @()
    foreach ($dc in $dcs) {
        try {
            $eventos = Get-WinEvent -ComputerName $dc -FilterHashtable $filtro -ErrorAction Stop
            $todosLosEventos += $eventos
        }
        catch [System.Diagnostics.Eventing.Reader.EventLogNotFoundException] {
            Write-Host "Sin eventos 4625 en $dc en el rango indicado." -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "No se pudo consultar $dc : $($_.Exception.Message)"
        }
    }

    if (-not $todosLosEventos) {
        Write-Host "No se encontraron eventos 4625 en ningun DC en el rango solicitado." -ForegroundColor Green
        exit 0
    }

    $resultado = $todosLosEventos | Select-Object `
        TimeCreated,
        @{N = 'CuentaObjetivo'; E = { $_.Properties[5].Value } },
        @{N = 'OrigenEstacion'; E = { $_.Properties[13].Value } },
        @{N = 'OrigenIP'; E = { $_.Properties[19].Value } },
        @{N = 'CodigoFallo'; E = { $_.Properties[7].Value } }

    if ($Usuario) {
        $resultado = $resultado | Where-Object { $_.CuentaObjetivo -eq $Usuario }
    }

    if (-not $resultado) {
        Write-Host "No hay eventos 4625 para el filtro solicitado." -ForegroundColor Green
        exit 0
    }

    Write-Host "`nTotal de fallos de autenticacion encontrados: $($resultado.Count)`n" -ForegroundColor Yellow

    # Deteccion de password spraying: mismo origen, muchas cuentas distintas
    $porOrigen = $resultado | Group-Object OrigenIP
    $sprayingSospechoso = $porOrigen | Where-Object {
        ($_.Group.CuentaObjetivo | Select-Object -Unique).Count -ge $UmbralCuentasDistintas
    }

    if ($sprayingSospechoso) {
        Write-Host "[AVISO] Posible PASSWORD SPRAYING detectado:" -ForegroundColor Red
        foreach ($grupo in $sprayingSospechoso) {
            $cuentas = ($grupo.Group.CuentaObjetivo | Select-Object -Unique) -join ', '
            Write-Host " - Origen $($grupo.Name): $($grupo.Group.Count) intentos contra $((($grupo.Group.CuentaObjetivo | Select-Object -Unique).Count)) cuentas ($cuentas)" -ForegroundColor Red
        }
    }

    # Deteccion de fuerza bruta dirigida: mismo origen, misma cuenta, muchos intentos
    $porOrigenYcuenta = $resultado | Group-Object OrigenIP, CuentaObjetivo | Where-Object { $_.Count -ge 5 }
    if ($porOrigenYcuenta) {
        Write-Host "`n[AVISO] Posible FUERZA BRUTA DIRIGIDA detectada:" -ForegroundColor Red
        foreach ($grupo in $porOrigenYcuenta) {
            Write-Host " - $($grupo.Name): $($grupo.Count) intentos" -ForegroundColor Red
        }
    }

    Write-Host ""
    $resultado | Sort-Object TimeCreated -Descending | Select-Object -First 50 | Format-Table -AutoSize

    if ($ExportarCSV) {
        $resultado | Export-Csv -Path $ExportarCSV -NoTypeInformation -Encoding UTF8
        Write-Host "`nEvidencia exportada a: $ExportarCSV" -ForegroundColor Cyan
    }
}
catch {
    Write-Error "Error al consultar eventos 4625: $($_.Exception.Message)"
    exit 1
}
