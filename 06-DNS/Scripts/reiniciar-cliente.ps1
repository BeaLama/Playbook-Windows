<#
===============================================================================
Reiniciar-DNSClient.ps1
===============================================================================

Autor:
    Equipo IT

Descripción:
    Reinicia el servicio DNS Client (Dnscache) y verifica su funcionamiento.

Funciones:

- Mostrar estado del servicio.
- Reiniciar el servicio.
- Verificar que ha arrancado.
- Comprobar resolución DNS.

===============================================================================
#>

Clear-Host

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " REINICIO DEL SERVICIO DNS CLIENT" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

##########################################################
# Estado inicial
##########################################################

Write-Host "`n[1] Estado actual del servicio" -ForegroundColor Yellow

Get-Service Dnscache |
Format-Table Status,StartType,Name -AutoSize

##########################################################
# Reinicio
##########################################################

Write-Host "`n[2] Reiniciando servicio..." -ForegroundColor Yellow

try{

    Restart-Service Dnscache -Force -ErrorAction Stop

    Write-Host "Servicio reiniciado correctamente." -ForegroundColor Green

}
catch{

    Write-Host "Error al reiniciar el servicio." -ForegroundColor Red
    Write-Host $_.Exception.Message

    exit

}

##########################################################
# Comprobación
##########################################################

Write-Host "`n[3] Estado tras el reinicio" -ForegroundColor Yellow

Get-Service Dnscache |
Format-Table Status,StartType,Name -AutoSize

##########################################################
# Prueba DNS
##########################################################

Write-Host "`n[4] Probando resolución DNS..." -ForegroundColor Yellow

$Dominios = @(
"google.com",
"microsoft.com"
)

foreach($Dominio in $Dominios){

    try{

        Resolve-DnsName $Dominio -ErrorAction Stop | Out-Null

        Write-Host "[OK] $Dominio" -ForegroundColor Green

    }
    catch{

        Write-Host "[ERROR] $Dominio" -ForegroundColor Red

    }

}

##########################################################
# Final
##########################################################

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " OPERACIÓN FINALIZADA" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan