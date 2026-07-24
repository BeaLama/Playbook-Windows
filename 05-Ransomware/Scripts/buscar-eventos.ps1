<#
===============================================================================
Buscar-Eventos.ps1
===============================================================================

Autor:
    Equipo IT

Descripción:
    Busca eventos relevantes relacionados con una posible infección de malware
    o ransomware.

Funciones:

- Eventos recientes de Microsoft Defender.
- Eventos de PowerShell.
- Eventos de inicio de sesión.
- Errores críticos del sistema.
- Exportación a informe.

===============================================================================
#>

Clear-Host

$Fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$Informe = ".\Informe_Eventos_$Fecha.txt"

function Escribir {

    param(
        [string]$Texto,
        [ConsoleColor]$Color = "White"
    )

    Write-Host $Texto -ForegroundColor $Color
    Add-Content -Path $Informe -Value $Texto

}

Escribir "===================================================" Cyan
Escribir " EVENTOS DEL SISTEMA" Cyan
Escribir "===================================================" Cyan
Escribir ""

###############################################################################
# MICROSOFT DEFENDER
###############################################################################

Escribir "===============================================" Yellow
Escribir "MICROSOFT DEFENDER"
Escribir "===============================================" Yellow

try{

Get-WinEvent `
-LogName "Microsoft-Windows-Windows Defender/Operational" `
-MaxEvents 30 |

Select TimeCreated,Id,LevelDisplayName,Message |

ForEach-Object{

Escribir ""
Escribir "Fecha : $($_.TimeCreated)" Green
Escribir "ID    : $($_.Id)"
Escribir "Nivel : $($_.LevelDisplayName)"
Escribir "Evento:"
Escribir $_.Message

}

}
catch{

Escribir "No se pudo acceder al registro de Defender." Red

}

###############################################################################
# POWERSHELL
###############################################################################

Escribir ""
Escribir "===============================================" Yellow
Escribir "POWERSHELL"
Escribir "===============================================" Yellow

try{

Get-WinEvent `
-LogName "Windows PowerShell" `
-MaxEvents 20 |

Select TimeCreated,Id,Message |

ForEach-Object{

Escribir ""
Escribir "Fecha : $($_.TimeCreated)" Green
Escribir "ID    : $($_.Id)"
Escribir $_.Message

}

}
catch{}

###############################################################################
# INICIOS DE SESIÓN
###############################################################################

Escribir ""
Escribir "===============================================" Yellow
Escribir "INICIOS DE SESIÓN"
Escribir "===============================================" Yellow

try{

Get-WinEvent `
-FilterHashtable @{
LogName='Security'
Id=4624,4625
} `
-MaxEvents 20 |

Select TimeCreated,Id |

ForEach-Object{

Escribir "$($_.TimeCreated)  Evento: $($_.Id)"

}

}
catch{

Escribir "No fue posible consultar el registro Security." Red

}

###############################################################################
# ERRORES CRÍTICOS DEL SISTEMA
###############################################################################

Escribir ""
Escribir "===============================================" Yellow
Escribir "ERRORES DEL SISTEMA"
Escribir "===============================================" Yellow

Get-WinEvent `
-LogName System `
-MaxEvents 30 |

Where-Object{

$_.LevelDisplayName -eq "Error" -or
$_.LevelDisplayName -eq "Critical"

} |

Select TimeCreated,ProviderName,Id |

ForEach-Object{

Escribir "$($_.TimeCreated)"
Escribir "$($_.ProviderName)"
Escribir "Evento: $($_.Id)"
Escribir ""

}

###############################################################################
# RESUMEN
###############################################################################

Escribir ""
Escribir "===================================================" Cyan
Escribir " RESUMEN" Cyan
Escribir "===================================================" Cyan

Escribir ""
Escribir "Revise especialmente:"
Escribir "- Eventos de Defender."
Escribir "- Errores críticos."
Escribir "- Inicios de sesión sospechosos."
Escribir "- Ejecuciones de PowerShell no autorizadas."

Escribir ""
Escribir "Informe generado:"
Escribir $Informe Green