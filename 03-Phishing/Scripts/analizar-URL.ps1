<#
===============================================================================
Analizar-URL.ps1
===============================================================================

Autor:
    Equipo IT

Descripción:
    Analiza una URL potencialmente maliciosa obteniendo información útil
    durante una investigación de phishing.

Características:

- Extrae el dominio.
- Obtiene la IP.
- Consulta los registros DNS.
- Comprueba el certificado SSL.
- Detecta dominios Punycode.
- Comprueba si utiliza HTTPS.
- Comprueba si utiliza una IP en lugar de un dominio.
- Genera un informe.

Uso:

.\Analizar-URL.ps1 -URL "https://login.microsoft.com.seguridad-falsa.com"

===============================================================================
#>

param(

    [Parameter(Mandatory=$true)]
    [string]$URL

)

Clear-Host

$Fecha = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$Informe = ".\Informe_URL_$Fecha.txt"

function Escribir {

    param(

        [string]$Texto,
        [ConsoleColor]$Color = "White"

    )

    Write-Host $Texto -ForegroundColor $Color
    Add-Content -Path $Informe -Value $Texto

}

Escribir "=============================================" Cyan
Escribir " ANALISIS DE URL " Cyan
Escribir "=============================================" Cyan
Escribir ""

############################################################
# VALIDAR URL
############################################################

try{

    $Uri = [System.Uri]$URL

}
catch{

    Escribir "URL no válida." Red
    return

}

$Dominio = $Uri.Host

Escribir "URL:"
Escribir $URL Green
Escribir ""

Escribir "Dominio:"
Escribir $Dominio Green
Escribir ""

############################################################
# HTTPS
############################################################

Escribir "PROTOCOLO" Cyan

if($Uri.Scheme -eq "https")
{
    Escribir "HTTPS detectado." Green
}
else
{
    Escribir "La URL NO utiliza HTTPS." Yellow
}

Escribir ""

############################################################
# PUNYCODE
############################################################

Escribir "PUNYCODE" Cyan

if($Dominio -match "^xn--")
{
    Escribir "Dominio Punycode detectado." Yellow
}
else
{
    Escribir "No se detecta Punycode." Green
}

Escribir ""

############################################################
# ¿ES UNA IP?
############################################################

Escribir "HOST" Cyan

if($Dominio -match "^\d{1,3}(\.\d{1,3}){3}$")
{
    Escribir "La URL utiliza una dirección IP." Yellow
}
else
{
    Escribir "La URL utiliza un nombre de dominio." Green
}

Escribir ""

############################################################
# DNS
############################################################

Escribir "DNS" Cyan

try{

Resolve-DnsName $Dominio |
Select Name,Type,IPAddress |
Format-Table

Resolve-DnsName $Dominio |
Out-File -Append $Informe

}
catch{

Escribir "No se ha podido resolver el dominio." Red

}

Escribir ""

############################################################
# IP
############################################################

Escribir "DIRECCIONES IP" Cyan

try{

$IPs = [System.Net.Dns]::GetHostAddresses($Dominio)

foreach($IP in $IPs)
{
    Escribir $IP.IPAddressToString Green
}

}
catch{

Escribir "No se pudo obtener la IP." Red

}

Escribir ""

############################################################
# CERTIFICADO SSL
############################################################

Escribir "CERTIFICADO SSL" Cyan

try{

$Tcp = New-Object Net.Sockets.TcpClient($Dominio,443)

$SSL = New-Object Net.Security.SslStream($Tcp.GetStream(),$false,
({$true}))

$SSL.AuthenticateAsClient($Dominio)

$Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SSL.RemoteCertificate)

Escribir "Emitido para:"
Escribir $Cert.Subject Green

Escribir ""

Escribir "Emisor:"
Escribir $Cert.Issuer Green

Escribir ""

Escribir "Caduca:"
Escribir $Cert.NotAfter Green

$SSL.Dispose()
$Tcp.Close()

}
catch{

Escribir "No se pudo obtener el certificado." Yellow

}

Escribir ""

############################################################
# CABECERAS HTTP
############################################################

Escribir "CABECERAS HTTP" Cyan

try{

$Respuesta = Invoke-WebRequest `
-Uri $URL `
-Method Head `
-TimeoutSec 10

$Respuesta.Headers |
Out-String |
Tee-Object -FilePath $Informe -Append

Write-Host $Respuesta.Headers

}
catch{

Escribir "No fue posible obtener las cabeceras." Yellow

}

Escribir ""

############################################################
# ADVERTENCIAS
############################################################

Escribir "COMPROBACIONES" Cyan

if($Dominio.Length -gt 40)
{
    Escribir "Dominio excesivamente largo." Yellow
}

if($Dominio.Split(".").Count -gt 4)
{
    Escribir "Gran cantidad de subdominios." Yellow
}

if($Dominio -match "-")
{
    Escribir "Dominio con múltiples guiones." Yellow
}

if($Dominio -match "\d")
{
    Escribir "Dominio contiene números." Yellow
}

Escribir ""

############################################################
# RECOMENDACIONES
############################################################

Escribir "RECOMENDACIONES" Cyan

Escribir "- Revisar la URL en VirusTotal."
Escribir "- Revisar la URL en URLScan."
Escribir "- Revisar el dominio en AbuseIPDB."
Escribir "- Comprobar la antigüedad del dominio mediante WHOIS."
Escribir "- Verificar si pertenece a una campaña de phishing."

Escribir ""

############################################################
# FINAL
############################################################

Escribir "=============================================" Green
Escribir " ANALISIS FINALIZADO " Green
Escribir "=============================================" Green

Escribir ""
Escribir "Informe generado:"
Escribir $Informe Green