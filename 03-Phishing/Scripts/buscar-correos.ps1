<#
===============================================================================
Buscar-Correos.ps1
===============================================================================

Autor:
    Equipo IT

Descripción:
    Busca un correo de phishing en Exchange Online mediante diferentes
    criterios para determinar si ha llegado a otros usuarios.

Requisitos:

- Exchange Online Management Module
- Permisos de Compliance Search
- PowerShell 7 o Windows PowerShell 5.1

Uso:

.\Buscar-Correos.ps1 `
    -NombreBusqueda "Phishing-Julio" `
    -Remitente "facturas@empresa-falsa.com"

Ejemplo:

.\Buscar-Correos.ps1 `
    -NombreBusqueda "Campaña-Phishing-001" `
    -Asunto "Actualización de contraseña"

===============================================================================
#>

param(

    [Parameter(Mandatory=$true)]
    [string]$NombreBusqueda,

    [string]$Remitente,

    [string]$Asunto,

    [string]$Dominio,

    [string]$URL

)

Clear-Host

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " BUSQUEDA DE CORREOS DE PHISHING " -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

#############################################################
# COMPROBAR CONEXIÓN
#############################################################

if (-not (Get-Command Connect-IPPSSession -ErrorAction SilentlyContinue))
{
    Write-Host ""
    Write-Host "No se encuentra el módulo Exchange Online." -ForegroundColor Red
    Write-Host ""
    return
}

#############################################################
# CONEXIÓN
#############################################################

Write-Host "[+] Conectando con Microsoft Purview..." -ForegroundColor Yellow

Connect-IPPSSession

#############################################################
# CONSTRUIR CONSULTA
#############################################################

$filtros = @()

if($Remitente)
{
    $filtros += "from:$Remitente"
}

if($Asunto)
{
    $filtros += "subject:`"$Asunto`""
}

if($Dominio)
{
    $filtros += "$Dominio"
}

if($URL)
{
    $filtros += "$URL"
}

$Consulta = $filtros -join " AND "

Write-Host ""
Write-Host "Consulta generada:" -ForegroundColor Green
Write-Host $Consulta
Write-Host ""

#############################################################
# CREAR BÚSQUEDA
#############################################################

Write-Host "[+] Creando búsqueda..." -ForegroundColor Yellow

New-ComplianceSearch `
-Name $NombreBusqueda `
-ExchangeLocation All `
-ContentMatchQuery $Consulta

#############################################################
# INICIAR
#############################################################

Write-Host "[+] Ejecutando búsqueda..." -ForegroundColor Yellow

Start-ComplianceSearch $NombreBusqueda

#############################################################
# ESPERAR FINALIZACIÓN
#############################################################

Write-Host ""
Write-Host "Esperando resultados..." -ForegroundColor Cyan

do{

    Start-Sleep -Seconds 5

    $Estado = Get-ComplianceSearch $NombreBusqueda

    Write-Host "Estado:" $Estado.Status

}
until($Estado.Status -eq "Completed")

#############################################################
# RESULTADOS
#############################################################

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host " RESULTADOS " -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""

$Estado |
Select-Object `
Name,
Status,
Items,
Size,
SuccessResults

Write-Host ""
Write-Host "Búsqueda finalizada correctamente." -ForegroundColor Green

Write-Host ""
Write-Host "Si se localizaron mensajes, continuar con el TASK-012." `
-ForegroundColor Yellow

Write-Host ""
Write-Host "Después de revisar los resultados puedes eliminar la búsqueda con:"
Write-Host ""
Write-Host "Remove-ComplianceSearch $NombreBusqueda"
Write-Host ""