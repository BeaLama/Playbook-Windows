<#
===============================================================================
Analizar-Equipo.ps1
===============================================================================

Autor:
    Equipo IT

Descripción:
    Script de comprobación rápida tras un posible incidente de phishing.

Objetivos:

- Comprobar procesos sospechosos.
- Mostrar conexiones de red activas.
- Detectar tareas programadas recientes.
- Mostrar programas instalados recientemente.
- Comprobar elementos de inicio automático.
- Revisar estado del antivirus.
- Exportar toda la información a un informe.

Compatible con:
    Windows 10
    Windows 11
    Windows Server 2019+
===============================================================================
#>

Clear-Host

$Fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$Informe = ".\Informe_Phishing_$Fecha.txt"

function Escribir {

    param(
        [string]$Texto,
        [ConsoleColor]$Color = "White"
    )

    Write-Host $Texto -ForegroundColor $Color
    Add-Content -Path $Informe -Value $Texto

}

Escribir "==================================================" Cyan
Escribir " ANALISIS DEL EQUIPO " Cyan
Escribir "==================================================" Cyan
Escribir ""

##########################################################
# INFORMACIÓN GENERAL
##########################################################

Escribir "[+] Equipo" Yellow

hostname | Tee-Object -FilePath $Informe -Append

Escribir ""
Escribir "[+] Usuario actual" Yellow

whoami | Tee-Object -FilePath $Informe -Append

##########################################################
# PROCESOS
##########################################################

Escribir ""
Escribir "==================================================" Cyan
Escribir "PROCESOS CON MAYOR CONSUMO DE MEMORIA" Cyan
Escribir "==================================================" Cyan

Get-Process |
Sort-Object WorkingSet -Descending |
Select-Object -First 15 Name,Id,
@{
Name="RAM_MB"
Expression={[math]::Round($_.WorkingSet/1MB,2)}
} |
Tee-Object -FilePath $Informe -Append

##########################################################
# CONEXIONES
##########################################################

Escribir ""
Escribir "==================================================" Cyan
Escribir "CONEXIONES ACTIVAS" Cyan
Escribir "==================================================" Cyan

netstat -ano |
Tee-Object -FilePath $Informe -Append

##########################################################
# TAREAS PROGRAMADAS
##########################################################

Escribir ""
Escribir "==================================================" Cyan
Escribir "TAREAS PROGRAMADAS" Cyan
Escribir "==================================================" Cyan

Get-ScheduledTask |
Select-Object TaskName,State |
Tee-Object -FilePath $Informe -Append

##########################################################
# PROGRAMAS INSTALADOS
##########################################################

Escribir ""
Escribir "==================================================" Cyan
Escribir "PROGRAMAS INSTALADOS" Cyan
Escribir "==================================================" Cyan

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
Select-Object DisplayName,DisplayVersion |
Sort-Object DisplayName |
Tee-Object -FilePath $Informe -Append

##########################################################
# INICIO AUTOMÁTICO
##########################################################

Escribir ""
Escribir "==================================================" Cyan
Escribir "PROGRAMAS DE INICIO" Cyan
Escribir "==================================================" Cyan

Get-CimInstance Win32_StartupCommand |
Select-Object Name,Command |
Tee-Object -FilePath $Informe -Append

##########################################################
# WINDOWS DEFENDER
##########################################################

Escribir ""
Escribir "==================================================" Cyan
Escribir "ESTADO DEL ANTIVIRUS" Cyan
Escribir "==================================================" Cyan

try{

Get-MpComputerStatus |
Select-Object `
AMServiceEnabled,
AntivirusEnabled,
RealTimeProtectionEnabled,
IoavProtectionEnabled,
AntispywareEnabled |
Tee-Object -FilePath $Informe -Append

}
catch{

Escribir "No ha sido posible consultar Microsoft Defender." Red

}

##########################################################
# SERVICIOS RECIENTES
##########################################################

Escribir ""
Escribir "==================================================" Cyan
Escribir "SERVICIOS EN EJECUCION" Cyan
Escribir "==================================================" Cyan

Get-Service |
Where-Object {$_.Status -eq "Running"} |
Sort-Object DisplayName |
Select-Object DisplayName,Status |
Tee-Object -FilePath $Informe -Append

##########################################################
# EVENTOS RECIENTES
##########################################################

Escribir ""
Escribir "==================================================" Cyan
Escribir "ULTIMOS EVENTOS DE SEGURIDAD" Cyan
Escribir "==================================================" Cyan

try{

Get-WinEvent `
-LogName Security `
-MaxEvents 20 |
Select-Object TimeCreated,Id,LevelDisplayName |
Tee-Object -FilePath $Informe -Append

}
catch{

Escribir "No ha sido posible leer el registro Security." Red

}

##########################################################
# FINAL
##########################################################

Escribir ""
Escribir "==================================================" Green
Escribir "ANALISIS FINALIZADO" Green
Escribir "==================================================" Green
Escribir ""
Escribir "Informe generado:" Green
Escribir $Informe Green