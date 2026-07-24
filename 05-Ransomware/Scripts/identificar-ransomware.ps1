<#
===============================================================================
Identificar-Ransomware.ps1
===============================================================================

Autor:
    Equipo IT

Descripción:
    Recopila indicadores que ayuden a identificar la posible familia de
    ransomware presente en el sistema.

Funciones:

- Buscar notas de rescate.
- Buscar extensiones desconocidas.
- Revisar procesos con alto consumo.
- Revisar Shadow Copies.
- Revisar eventos recientes de Defender.
- Generar un informe.

===============================================================================
#>

Clear-Host

$Fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$Informe = ".\Informe_Ransomware_$Fecha.txt"

function Escribir {

    param(
        [string]$Texto,
        [ConsoleColor]$Color = "White"
    )

    Write-Host $Texto -ForegroundColor $Color
    Add-Content $Informe $Texto

}

Escribir "==================================================" Cyan
Escribir " IDENTIFICACIÓN DE RANSOMWARE" Cyan
Escribir "==================================================" Cyan
Escribir ""

###############################################################################
# INFORMACIÓN GENERAL
###############################################################################

Escribir "Fecha: $(Get-Date)"
Escribir "Equipo: $env:COMPUTERNAME"
Escribir "Usuario: $env:USERNAME"

###############################################################################
# NOTAS DE RESCATE
###############################################################################

Escribir ""
Escribir "==========================================" Yellow
Escribir "NOTAS DE RESCATE"
Escribir "==========================================" Yellow

$Patrones = @(
"*README*",
"*RECOVER*",
"*RESTORE*",
"*DECRYPT*",
"*HOW_TO*",
"*HELP*",
"*.hta",
"*.html",
"*.txt"
)

foreach($Patron in $Patrones){

    Get-ChildItem C:\Users `
    -Recurse `
    -Filter $Patron `
    -ErrorAction SilentlyContinue |

    Select-Object FullName,LastWriteTime |

    ForEach-Object{

        Escribir $_.FullName Red

    }

}

###############################################################################
# EXTENSIONES SOSPECHOSAS
###############################################################################

Escribir ""
Escribir "==========================================" Yellow
Escribir "EXTENSIONES DESCONOCIDAS"
Escribir "==========================================" Yellow

Get-ChildItem C:\Users `
-Recurse `
-File `
-ErrorAction SilentlyContinue |

Where-Object{

$_.Extension.Length -gt 6

} |

Select-Object -First 100 FullName |

ForEach-Object{

    Escribir $_.FullName

}

###############################################################################
# PROCESOS CON MAYOR CONSUMO
###############################################################################

Escribir ""
Escribir "==========================================" Yellow
Escribir "PROCESOS"
Escribir "==========================================" Yellow

Get-Process |

Sort-Object CPU -Descending |

Select-Object -First 15 Name,Id,CPU |

ForEach-Object{

    Escribir "$($_.Name)  PID:$($_.Id)  CPU:$($_.CPU)"

}

###############################################################################
# SHADOW COPIES
###############################################################################

Escribir ""
Escribir "==========================================" Yellow
Escribir "SHADOW COPIES"
Escribir "==========================================" Yellow

$vss = vssadmin list shadows 2>$null

if($LASTEXITCODE -eq 0){

    Escribir "Shadow Copies disponibles."

}else{

    Escribir "No existen Shadow Copies o han sido eliminadas." Red

}

###############################################################################
# EVENTOS DEFENDER
###############################################################################

Escribir ""
Escribir "==========================================" Yellow
Escribir "EVENTOS MICROSOFT DEFENDER"
Escribir "==========================================" Yellow

try{

Get-WinEvent `
-LogName "Microsoft-Windows-Windows Defender/Operational" `
-MaxEvents 20 |

Select TimeCreated,Id,LevelDisplayName |

ForEach-Object{

Escribir "$($_.TimeCreated)  ID:$($_.Id)"

}

}
catch{

Escribir "No se pudieron obtener eventos de Defender."

}

###############################################################################
# HASH DE EJECUTABLES RECIENTES
###############################################################################

Escribir ""
Escribir "==========================================" Yellow
Escribir "EJECUTABLES RECIENTES"
Escribir "==========================================" Yellow

Get-ChildItem C:\Users `
-Recurse `
-Include *.exe `
-ErrorAction SilentlyContinue |

Sort-Object LastWriteTime -Descending |

Select-Object -First 10 |

ForEach-Object{

    try{

        $Hash = Get-FileHash $_.FullName -Algorithm SHA256

        Escribir ""
        Escribir $_.FullName Green
        Escribir $Hash.Hash

    }
    catch{}

}

###############################################################################
# FINAL
###############################################################################

Escribir ""
Escribir "==================================================" Cyan
Escribir " ANÁLISIS FINALIZADO" Cyan
Escribir "==================================================" Cyan
Escribir ""
Escribir "Informe generado:"
Escribir $Informe Green