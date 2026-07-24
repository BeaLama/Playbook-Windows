<#
===============================================================================
Comprobar-Servidor-DNS.ps1
===============================================================================

Autor:
    Equipo IT

Descripción:
    Comprueba el estado de los servidores DNS configurados en el equipo.

Funciones:

- Detectar los servidores DNS configurados.
- Comprobar conectividad (Ping).
- Comprobar puerto DNS (53).
- Realizar una consulta DNS.
- Mostrar un resumen del estado.

===============================================================================
#>

Clear-Host

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " COMPROBACIÓN DE SERVIDORES DNS" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

##########################################################
# Obtener servidores DNS
##########################################################

$ServidoresDNS = Get-DnsClientServerAddress -AddressFamily IPv4 |
Where-Object { $_.ServerAddresses } |
Select-Object -ExpandProperty ServerAddresses -Unique

if ($ServidoresDNS.Count -eq 0) {

    Write-Host ""
    Write-Host "No hay servidores DNS configurados." -ForegroundColor Red
    exit

}

##########################################################
# Comprobación
##########################################################

foreach ($Servidor in $ServidoresDNS) {

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Yellow
    Write-Host "Servidor DNS: $Servidor"
    Write-Host "==================================================" -ForegroundColor Yellow

    ###########################
    # Ping
    ###########################

    Write-Host ""
    Write-Host "[1] Conectividad ICMP"

    if (Test-Connection $Servidor -Count 2 -Quiet) {

        Write-Host "OK - El servidor responde al Ping." -ForegroundColor Green

    }
    else {

        Write-Host "ERROR - No responde al Ping." -ForegroundColor Red

    }

    ###########################
    # Puerto 53
    ###########################

    Write-Host ""
    Write-Host "[2] Puerto DNS (53)"

    $Puerto = Test-NetConnection `
        -ComputerName $Servidor `
        -Port 53 `
        -WarningAction SilentlyContinue

    if ($Puerto.TcpTestSucceeded) {

        Write-Host "OK - Puerto 53 accesible." -ForegroundColor Green

    }
    else {

        Write-Host "ERROR - Puerto 53 cerrado." -ForegroundColor Red

    }

    ###########################
    # Consulta DNS
    ###########################

    Write-Host ""
    Write-Host "[3] Consulta DNS"

    try {

        Resolve-DnsName `
            -Name google.com `
            -Server $Servidor `
            -ErrorAction Stop | Out-Null

        Write-Host "OK - El servidor responde correctamente." -ForegroundColor Green

    }
    catch {

        Write-Host "ERROR - No responde a consultas DNS." -ForegroundColor Red

    }

}

##########################################################
# Fin
##########################################################

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " COMPROBACIÓN FINALIZADA" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan