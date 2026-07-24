<#
.SYNOPSIS
    INC-002 - Revisa las reglas de bandeja de entrada de un buzon y resalta las
    potencialmente maliciosas (reenvio externo, eliminacion silenciosa).

.DESCRIPTION
    Usado en TASK-003 para detectar mecanismos de persistencia habituales en
    Business Email Compromise (BEC): reglas que reenvian o redirigen correo a
    dominios externos, o que eliminan/mueven mensajes automaticamente para
    ocultar respuestas al atacante (ej. respuestas de un fraude de facturas).

.PARAMETER Mailbox
    Direccion de correo del buzon a revisar (obligatorio).

.PARAMETER DominiosPropios
    Lista de dominios propios de la organizacion (para distinguir reenvios
    internos legitimos de reenvios externos sospechosos). Por defecto,
    intenta detectarlos automaticamente a partir del dominio del propio buzon.

.PARAMETER ExportarCSV
    Ruta opcional donde exportar el resultado como evidencia.

.EXAMPLE
    .\Revisar-ReglasBuzon.ps1 -Mailbox usuario@empresa.com

.EXAMPLE
    .\Revisar-ReglasBuzon.ps1 -Mailbox usuario@empresa.com -DominiosPropios "empresa.com","empresa.es"

.NOTES
    Requiere el modulo ExchangeOnlineManagement y rol Exchange Administrator (o
    View-Only Recipients + Mail Recipients para solo lectura).
    Conectar previamente con: Connect-ExchangeOnline
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Mailbox,

    [string[]]$DominiosPropios,

    [string]$ExportarCSV
)

$ErrorActionPreference = 'Stop'

try {
    if (-not (Get-ConnectionInformation -ErrorAction SilentlyContinue)) {
        Write-Error "No hay sesion activa de Exchange Online. Ejecuta: Connect-ExchangeOnline"
        exit 1
    }

    if (-not $DominiosPropios) {
        $DominiosPropios = @($Mailbox.Split('@')[1])
        Write-Host "Dominio propio detectado automaticamente: $($DominiosPropios -join ', ')" -ForegroundColor Cyan
        Write-Host "(usa -DominiosPropios para especificar mas de uno si aplica)`n" -ForegroundColor Cyan
    }

    Write-Host "Consultando reglas de bandeja de entrada de '$Mailbox'..." -ForegroundColor Cyan

    $reglas = Get-InboxRule -Mailbox $Mailbox

    if (-not $reglas) {
        Write-Host "El buzon no tiene reglas de bandeja de entrada configuradas." -ForegroundColor Green
        exit 0
    }

    $resultado = foreach ($regla in $reglas) {
        $destinosExternos = @()
        foreach ($destino in @($regla.ForwardTo + $regla.ForwardAsAttachmentTo + $regla.RedirectTo)) {
            if ($destino) {
                $dominioDestino = ($destino -replace '.*SMTP:', '') -replace '.*@', '' -replace '\]$', ''
                if ($DominiosPropios -notcontains $dominioDestino) {
                    $destinosExternos += $destino
                }
            }
        }

        [PSCustomObject]@{
            Nombre               = $regla.Name
            Habilitada           = $regla.Enabled
            ReenvioExterno       = ($destinosExternos.Count -gt 0)
            DestinosExternos     = ($destinosExternos -join '; ')
            EliminaMensaje       = $regla.DeleteMessage
            MarcaComoLeido       = $regla.MarkAsRead
            MueveACarpeta        = $regla.MoveToFolder
            Condiciones          = ($regla | Select-Object -ExpandProperty From, SubjectContainsWords -ErrorAction SilentlyContinue) -join '; '
        }
    }

    Write-Host ""
    $resultado | Format-Table Nombre, Habilitada, ReenvioExterno, DestinosExternos, EliminaMensaje -AutoSize

    $sospechosas = $resultado | Where-Object { $_.ReenvioExterno -or ($_.EliminaMensaje -and $_.Habilitada) }
    if ($sospechosas) {
        Write-Host "`n[AVISO] Reglas potencialmente maliciosas detectadas:" -ForegroundColor Red
        $sospechosas | ForEach-Object {
            $motivo = @()
            if ($_.ReenvioExterno) { $motivo += "reenvio a dominio externo ($($_.DestinosExternos))" }
            if ($_.EliminaMensaje -and $_.Habilitada) { $motivo += "elimina mensajes automaticamente" }
            Write-Host " - '$($_.Nombre)': $($motivo -join ' + ')" -ForegroundColor Red
        }
        Write-Host "`nAccion recomendada (TASK-004): Remove-InboxRule -Mailbox '$Mailbox' -Identity '<Nombre>' -Confirm:`$false" -ForegroundColor Yellow
    }
    else {
        Write-Host "`nNo se detectaron reglas con patron de reenvio externo o eliminacion automatica." -ForegroundColor Green
    }

    if ($ExportarCSV) {
        $resultado | Export-Csv -Path $ExportarCSV -NoTypeInformation -Encoding UTF8
        Write-Host "`nEvidencia exportada a: $ExportarCSV" -ForegroundColor Cyan
    }
}
catch {
    Write-Error "Error al consultar reglas de buzon: $($_.Exception.Message)"
    exit 1
}
