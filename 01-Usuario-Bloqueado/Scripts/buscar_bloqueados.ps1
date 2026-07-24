<#
.SYNOPSIS
    INC-001 - Busca todas las cuentas de Active Directory actualmente bloqueadas.

.DESCRIPTION
    Consulta el PDC Emulator del dominio (fuente autoritativa del atributo LockedOut,
    ver Teoria.md #2) y devuelve la lista de cuentas bloqueadas con sus datos clave
    para diagnóstico rápido en TASK-01.

.PARAMETER ExportarCSV
    Ruta opcional donde exportar el resultado como evidencia para el ticket.

.EXAMPLE
    .\buscar_bloqueados.ps1

.EXAMPLE
    .\buscar_bloqueados.ps1 -ExportarCSV "C:\Evidencias\INC-001_bloqueados.csv"

.NOTES
    Requiere el módulo ActiveDirectory (RSAT) y permisos de lectura sobre el dominio.
    Cuándo ejecutarlo: TASK-01, cuando se sospecha que el problema puede afectar a
    más de un usuario o se quiere confirmar rápidamente el alcance del incidente.
#>

[CmdletBinding()]
param(
    [string]$ExportarCSV
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory -ErrorAction Stop
}
catch {
    Write-Error "No se pudo cargar el módulo ActiveDirectory. Instala RSAT: Add-WindowsCapability -Online -Name 'Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0'"
    exit 1
}

try {
    $pdc = (Get-ADDomain).PDCEmulator
    Write-Host "Consultando PDC Emulator: $pdc" -ForegroundColor Cyan

    $bloqueados = Search-ADAccount -LockedOut -Server $pdc |
        Get-ADUser -Properties LockedOut, LastBadPasswordAttempt, BadPwdCount, Enabled, DistinguishedName -Server $pdc |
        Select-Object Name, SamAccountName, LockedOut, LastBadPasswordAttempt, BadPwdCount, Enabled, DistinguishedName

    if (-not $bloqueados) {
        Write-Host "No hay cuentas bloqueadas actualmente en el dominio." -ForegroundColor Green
        exit 0
    }

    Write-Host "`nCuentas bloqueadas encontradas: $($bloqueados.Count)`n" -ForegroundColor Yellow
    $bloqueados | Format-Table -AutoSize

    if ($ExportarCSV) {
        $bloqueados | Export-Csv -Path $ExportarCSV -NoTypeInformation -Encoding UTF8
        Write-Host "Evidencia exportada a: $ExportarCSV" -ForegroundColor Cyan
    }
}
catch {
    Write-Error "Error al consultar cuentas bloqueadas: $($_.Exception.Message)"
    exit 1
}
