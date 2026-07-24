<#
.SYNOPSIS
    INC-001 - Desbloquea una cuenta de AD y verifica el resultado (TASK-04 + TASK-05).

.DESCRIPTION
    Ejecuta Unlock-ADAccount contra el PDC Emulator, verifica inmediatamente que
    LockedOut ha pasado a False, y registra la accion en un log local para evidencias.
    NO ejecutar este script si TASK-03 ha determinado que el bloqueo es sospechoso:
    en ese caso, el playbook indica escalar a INC-002 en lugar de desbloquear.

.PARAMETER Usuario
    sAMAccountName del usuario a desbloquear.

.PARAMETER LogPath
    Ruta del log de auditoria local. Por defecto, C:\Evidencias\INC-001_desbloqueos.log

.EXAMPLE
    .\desbloquear.ps1 -Usuario jperez

.NOTES
    Requiere permisos delegados de "Unlock account" sobre la OU del usuario
    (no requiere Domain Admin si la delegacion esta bien configurada).
    Cuando ejecutarlo: TASK-04, solo despues de completar TASK-01, TASK-02 y TASK-03.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Usuario,

    [string]$LogPath = "C:\Evidencias\INC-001_desbloqueos.log"
)

$ErrorActionPreference = 'Stop'

function Write-Log {
    param([string]$Mensaje)
    $linea = "{0:yyyy-MM-dd HH:mm:ss} UTC | {1} | Ejecutado por: {2} | {3}" -f `
        (Get-Date).ToUniversalTime(), $Usuario, $env:USERNAME, $Mensaje

    $logDir = Split-Path -Path $LogPath -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    Add-Content -Path $LogPath -Value $linea
    Write-Host $linea
}

try {
    Import-Module ActiveDirectory -ErrorAction Stop
    $pdc = (Get-ADDomain).PDCEmulator

    # Confirmacion explicita antes de actuar sobre una cuenta
    $estadoPrevio = Get-ADUser -Identity $Usuario -Server $pdc -Properties LockedOut

    if (-not $estadoPrevio.LockedOut) {
        Write-Log "ABORTADO: la cuenta no aparece bloqueada (LockedOut=False). No se ejecuta ninguna accion."
        Write-Host "La cuenta '$Usuario' no esta bloqueada. Revisa TASK-01 antes de continuar." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "Desbloqueando cuenta '$Usuario' via PDC Emulator ($pdc)..." -ForegroundColor Cyan
    Unlock-ADAccount -Identity $Usuario -Server $pdc

    Start-Sleep -Seconds 2

    $estadoPosterior = Get-ADUser -Identity $Usuario -Server $pdc -Properties LockedOut

    if ($estadoPosterior.LockedOut -eq $false) {
        Write-Log "EXITO: cuenta desbloqueada correctamente. Verificado LockedOut=False."
        Write-Host "Cuenta '$Usuario' desbloqueada y verificada correctamente." -ForegroundColor Green
    }
    else {
        Write-Log "ADVERTENCIA: se ejecuto Unlock-ADAccount pero LockedOut sigue en True."
        Write-Host "El comando se ejecuto pero la cuenta sigue apareciendo bloqueada. Puede indicar reintentos automaticos activos (ver TASK-02 / origen del bloqueo) o retraso de replicacion. Revisar TASK-05 del Playbook." -ForegroundColor Red
    }
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Error "No se pudo desbloquear la cuenta: $($_.Exception.Message)"
    exit 1
}
