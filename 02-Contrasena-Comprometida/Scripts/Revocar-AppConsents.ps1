<#
.SYNOPSIS
    INC-002 - Lista y opcionalmente revoca los consentimientos OAuth otorgados
    por un usuario a aplicaciones de terceros.

.DESCRIPTION
    Usado en TASK-003 (modo listado) para detectar aplicaciones con permisos
    amplios (Mail.Read, Files.ReadWrite.All, etc.) autorizadas durante la ventana
    de compromiso, y en TASK-004 (modo revocacion) para eliminar el consentimiento
    de una app concreta identificada como maliciosa. El consentimiento OAuth es
    un mecanismo de persistencia que SOBREVIVE a un cambio de contraseña.

.PARAMETER UserPrincipalName
    UPN del usuario a revisar (obligatorio).

.PARAMETER SoloListar
    Si se especifica, solo lista los consentimientos sin revocar nada.
    Uso recomendado en TASK-003.

.PARAMETER AppId
    Id de la aplicacion (ClientId) cuyo consentimiento se desea revocar.
    Obligatorio si NO se usa -SoloListar. Se obtiene del listado previo.

.PARAMETER PermisosDeRiesgo
    Lista de scopes considerados de alto riesgo para resaltar en el listado.
    Por defecto incluye los mas comunes en persistencia post-compromiso.

.EXAMPLE
    .\Revocar-AppConsents.ps1 -UserPrincipalName usuario@empresa.com -SoloListar

.EXAMPLE
    .\Revocar-AppConsents.ps1 -UserPrincipalName usuario@empresa.com -AppId "1234abcd-...-efgh5678"

.NOTES
    Requiere modulo Microsoft.Graph y rol Cloud Application Administrator o
    Application Administrator para revocar consentimientos.
    Conectar previamente con:
    Connect-MgGraph -Scopes "Directory.Read.All","DelegatedPermissionGrant.ReadWrite.All"
#>

[CmdletBinding(DefaultParameterSetName = 'Listar')]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(ParameterSetName = 'Listar')]
    [switch]$SoloListar,

    [Parameter(Mandatory = $true, ParameterSetName = 'Revocar')]
    [string]$AppId,

    [string[]]$PermisosDeRiesgo = @(
        'Mail.Read', 'Mail.ReadWrite', 'Mail.Send',
        'Files.ReadWrite.All', 'Files.Read.All',
        'Directory.ReadWrite.All', 'Directory.AccessAsUser.All',
        'offline_access'
    )
)

$ErrorActionPreference = 'Stop'

try {
    if (-not (Get-MgContext)) {
        Write-Error "No hay sesion activa de Microsoft Graph. Ejecuta: Connect-MgGraph -Scopes 'Directory.Read.All','DelegatedPermissionGrant.ReadWrite.All'"
        exit 1
    }

    $usuario = Get-MgUser -UserId $UserPrincipalName -Property Id, DisplayName
    Write-Host "Consultando consentimientos OAuth de '$($usuario.DisplayName)'..." -ForegroundColor Cyan

    $grants = Get-MgUserOauth2PermissionGrant -UserId $usuario.Id -All

    if (-not $grants) {
        Write-Host "El usuario no tiene consentimientos OAuth delegados registrados." -ForegroundColor Green
        exit 0
    }

    $resultado = foreach ($grant in $grants) {
        $app = Get-MgServicePrincipal -ServicePrincipalId $grant.ClientId -ErrorAction SilentlyContinue
        $scopes = $grant.Scope -split ' '
        $tieneRiesgo = ($scopes | Where-Object { $PermisosDeRiesgo -contains $_ }).Count -gt 0

        [PSCustomObject]@{
            AppNombre  = $app.DisplayName
            AppId      = $grant.ClientId
            Scopes     = $grant.Scope
            RiesgoAlto = $tieneRiesgo
            GrantId    = $grant.Id
        }
    }

    Write-Host ""
    $resultado | Format-Table AppNombre, AppId, RiesgoAlto, Scopes -AutoSize -Wrap

    $riesgosos = $resultado | Where-Object { $_.RiesgoAlto }
    if ($riesgosos) {
        Write-Host "`n[AVISO] Aplicaciones con permisos de riesgo alto detectadas:" -ForegroundColor Red
        $riesgosos | ForEach-Object { Write-Host " - $($_.AppNombre) (AppId: $($_.AppId)) -> $($_.Scopes)" -ForegroundColor Red }
    }

    if ($PSCmdlet.ParameterSetName -eq 'Revocar') {
        $grantObjetivo = $grants | Where-Object { $_.ClientId -eq $AppId }
        if (-not $grantObjetivo) {
            Write-Error "No se encontro ningun consentimiento activo para AppId '$AppId' en este usuario."
            exit 1
        }

        Write-Host "`nRevocando consentimiento de AppId '$AppId'..." -ForegroundColor Yellow
        Remove-MgOauth2PermissionGrant -OAuth2PermissionGrantId $grantObjetivo.Id -Confirm:$false
        Write-Host "Consentimiento revocado correctamente." -ForegroundColor Green
    }
    else {
        Write-Host "`nModo solo listado. Para revocar, ejecuta con -AppId <id> en lugar de -SoloListar." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "Error al procesar consentimientos OAuth: $($_.Exception.Message)"
    exit 1
}
