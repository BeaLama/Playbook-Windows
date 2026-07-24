<#
===============================================================================
Verificar-DNS.ps1
===============================================================================

Autor:
    Equipo IT

Descripción:
    Verifica la configuración DNS del equipo y realiza comprobaciones básicas.

Funciones:
    - Adaptadores de red activos.
    - Servidores DNS configurados.
    - Servicio DNS Client.
    - Resolución de nombres.
    - Informe por pantalla.

===============================================================================
#>

Clear-Host

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " VERIFICACIÓN DE CONFIGURACIÓN DNS" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

##########################################################
# Adaptadores activos
##########################################################

Write-Host "`n[1] Adaptadores de red activos" -ForegroundColor Yellow

Get-NetAdapter |
Where-Object Status -eq "Up" |
Format-Table `
Name,
InterfaceDescription,
Status,
LinkSpeed -AutoSize

##########################################################
# Configuración DNS
##########################################################

Write-Host "`n[2] Servidores DNS configurados" -ForegroundColor Yellow

Get-DnsClientServerAddress -AddressFamily IPv4 |
Where-Object {$_.ServerAddresses} |
Format-Table `
InterfaceAlias,
ServerAddresses -AutoSize

##########################################################
# Configuración IP
##########################################################

Write-Host "`n[3] Configuración IP" -ForegroundColor Yellow

Get-NetIPConfiguration |
Format-Table `
InterfaceAlias,
IPv4Address,
IPv4DefaultGateway -AutoSize

##########################################################
# Servicio DNS Client
##########################################################

Write-Host "`n[4] Servicio DNS Client" -ForegroundColor Yellow

Get-Service Dnscache |
Format-Table `
Status,
StartType,
Name -AutoSize

##########################################################
# Resolución DNS
##########################################################

Write-Host "`n[5] Prueba de resolución DNS" -ForegroundColor Yellow

$Dominios = @(
"google.com",
"microsoft.com",
"cloudflare.com"
)

foreach($Dominio in $Dominios){

    try{

        $Resultado = Resolve-DnsName $Dominio -ErrorAction Stop

        Write-Host "[OK] $Dominio" -ForegroundColor Green

        $Resultado |
        Where-Object Type -eq "A" |
        Select-Object Name,IPAddress

    }

    catch{

        Write-Host "[ERROR] No se pudo resolver $Dominio" -ForegroundColor Red

    }

    Write-Host ""

}

##########################################################
# Resumen
##########################################################

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " VERIFICACIÓN FINALIZADA" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan