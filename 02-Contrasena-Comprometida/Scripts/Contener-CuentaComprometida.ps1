<#
.SYNOPSIS
    INC-002 - Contiene una cuenta comprometida: deshabilita, revoca sesiones y
    opcionalmente fuerza cambio de contraseña.

.DESCRIPTION
    Ejecuta la contencion inmediata definida en TASK-002: deshabilita la cuenta
    en Entra ID (y en AD on-prem si el parametro -Hibrido esta presente), revoca
    todas las sesiones activas (Revoke-MgUserSignInSession) y registra la accion
    con timestamp UTC para evidencias.

.PARAMETER UserPrincipalName
    UPN del usuario a contener (obligatorio).

.PARAMETER Hibrido
    Si se especifica, tambien deshabilita la cuenta equivalente en Active Directory
    on-premises (requiere modulo ActiveDirectory y que el SamAccountName coincida
    con la parte local del UPN).

.PARAMETER LogPath
    Ruta del log de auditoria local. Por defecto, .\Evidencias\INC-002_contenciones.log

.EXAMPLE
    .\Contener-CuentaComprometida.ps1 -UserPrincipalName usuario@empresa.com

.EXAMPLE
    .\Contener-CuentaComprometida.ps1 -UserPrincipalName usuario@empresa.com -Hibrido

.NOTES
    Requiere modulo Microsoft.Graph y rol Security Administrator / User Administrator.
    Conectar previamente con: Connect-MgGraph -Scopes "User.ReadWrite.All"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [switch]$Hibrido,

    [string]$LogPath = ".\Evidencias\INC-002_contenciones.log"
)

$ErrorActionPreference = 'Stop'

function Write-Log {
    param([string]$Mensaje)
    $linea = "{0:yyyy-MM-dd HH:mm:ss} UTC | {1} | Ejecutado por: {2} | {3}" -f `
        (Get-Date).ToUniversalTime(), $UserPrincipalName, $env:USERNAME, $Mensaje

    $logDir = Split-Path -Path $LogPath -Parent
    if ($logDir -and -not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    Add-Content -Path $LogPath -Value $linea
    Write-Host $linea -ForegroundColor Cyan
}

try {
    if (-not (Get-MgContext)) {
        Write-Error "No hay sesion activa de Microsoft Graph. Ejecuta: Connect-MgGraph -Scopes 'User.ReadWrite.All'"
        exit 1
    }

    Write-Host "=== CONTENCION DE CUENTA COMPROMETIDA: $UserPrincipalName ===" -ForegroundColor Red

    # 1. Deshabilitar cuenta en Entra ID
    Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$false
    Write-Log "Cuenta deshabilitada en Entra ID."

    # 2. Revocar todas las sesiones activas (invalida tokens de refresco)
    Revoke-MgUserSignInSession -UserId $UserPrincipalName | Out-Null
    Write-Log "Sesiones y tokens de actualizacion revocados."

    # 3. Verificacion
    $usuario = Get-MgUser -UserId $UserPrincipalName -Property AccountEnabled, DisplayName
    if ($usuario.AccountEnabled -eq $false) {
        Write-Log "VERIFICADO: AccountEnabled=False."
        Write-Host "Contencion en Entra ID completada correctamente para '$($usuario.DisplayName)'." -ForegroundColor Green
    }
    else {
        Write-Log "ADVERTENCIA: AccountEnabled sigue en True tras la operacion."
        Write-Host "ATENCION: la cuenta no aparece deshabilitada tras la operacion. Verificar manualmente." -ForegroundColor Red
    }

    # 4. Contencion adicional on-premises si el entorno es hibrido
    if ($Hibrido) {
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
            $samAccountName = $UserPrincipalName.Split('@')[0]
            Disable-ADAccount -Identity $samAccountName
            Write-Log "Cuenta on-premises '$samAccountName' deshabilitada tambien (entorno hibrido)."
            Write-Host "Cuenta on-premises deshabilitada correctamente." -ForegroundColor Green
        }
        catch {
            Write-Log "ERROR al deshabilitar cuenta on-premises: $($_.Exception.Message)"
            Write-Error "No se pudo deshabilitar la cuenta on-premises: $($_.Exception.Message)"
        }
    }

    Write-Host "`nSiguiente paso: TASK-003 del Playbook (investigar alcance)." -ForegroundColor Yellow
}
catch {
    Write-Log "ERROR CRITICO durante la contencion: $($_.Exception.Message)"
    Write-Error "Fallo la contencion de la cuenta: $($_.Exception.Message)"
    exit 1
}
