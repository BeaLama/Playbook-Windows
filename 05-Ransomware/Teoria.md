# INC-005 — Ransomware · Teoría

> 🚧 Pendiente de desarrollo. Sigue el estandar de [00-Metodologia/Metodologia.md](../00-Metodologia/Metodologia.md).

Este documento contendra los conceptos minimos necesarios para entender el incidente "Ransomware", siguiendo el mismo patron aplicado en 01-Usuario-Bloqueado/Teoria.md.
# Teoría - Ransomware

## Introducción

El ransomware es un tipo de malware diseñado para impedir el acceso a la información de un sistema mediante el cifrado de archivos o el bloqueo del equipo. Tras completar el proceso de cifrado, el atacante exige el pago de un rescate (normalmente en criptomonedas) a cambio de proporcionar una supuesta clave de descifrado.

En la actualidad, el ransomware representa una de las amenazas más graves para organizaciones de cualquier tamaño, debido al impacto operativo, económico y reputacional que puede ocasionar.

A diferencia de otros tipos de malware, el objetivo principal del ransomware no suele ser permanecer oculto, sino interrumpir la actividad de la organización y ejercer presión para obtener un beneficio económico.

---

# ¿Qué es un ransomware?

Un ransomware es un software malicioso que cifra archivos, volúmenes completos o incluso servidores enteros, impidiendo su utilización hasta que se pague un rescate.

Actualmente, la mayoría de grupos de ransomware utilizan una estrategia conocida como **doble extorsión**, que consiste en:

1. Robar información sensible.
2. Cifrar los archivos.
3. Amenazar con publicar los datos robados si no se paga.

Algunos grupos han evolucionado incluso hacia la **triple extorsión**, añadiendo ataques DDoS o presión sobre clientes y proveedores.

---

# Objetivos del ransomware

Los objetivos habituales son:

- Cifrar información crítica.
- Interrumpir la actividad empresarial.
- Robar información confidencial.
- Exigir un rescate económico.
- Presionar mediante filtraciones públicas.
- Obtener persistencia hasta completar el ataque.

---

# Fases de un ataque

Un ataque moderno de ransomware suele desarrollarse en varias fases.

```text
Acceso inicial
      │
      ▼
Persistencia
      │
      ▼
Escalada de privilegios
      │
      ▼
Movimiento lateral
      │
      ▼
Reconocimiento interno
      │
      ▼
Exfiltración de datos
      │
      ▼
Cifrado masivo
      │
      ▼
Solicitud del rescate
```

En muchas ocasiones el cifrado es la última fase del ataque, después de varios días o incluso semanas de permanencia en la red.

---

# Vectores de entrada

Los atacantes pueden acceder a la infraestructura mediante diferentes técnicas.

## Phishing

Es uno de los métodos más utilizados.

Ejemplos:

- Documentos Office.
- PDFs maliciosos.
- Archivos ZIP.
- Enlaces fraudulentos.
- HTML adjuntos.

---

## Servicios expuestos

Especialmente:

- RDP.
- VPN.
- SSH.
- Citrix.
- Servidores web vulnerables.

---

## Vulnerabilidades

El ransomware suele aprovechar sistemas sin actualizar.

Ejemplos:

- Windows.
- Exchange.
- VMware ESXi.
- Navegadores.
- Servidores web.

---

## Robo de credenciales

Credenciales obtenidas mediante:

- Phishing.
- InfoStealers.
- Keyloggers.
- Filtraciones previas.
- Fuerza bruta.

---

# Comportamiento habitual

Una vez dentro de la organización, el atacante suele:

- Desactivar el antivirus.
- Deshabilitar Defender.
- Eliminar copias Shadow.
- Detener servicios.
- Robar información.
- Expandirse por Active Directory.
- Localizar servidores.
- Localizar NAS.
- Localizar copias de seguridad.
- Cifrar los datos.

---

# Tipos de ransomware

## Crypto Ransomware

Cifra los archivos manteniendo el sistema operativo funcional.

Es el más habitual.

---

## Locker Ransomware

Impide el acceso al sistema operativo.

El usuario no puede iniciar sesión.

---

## Leakware

Amenaza con publicar información robada.

Puede no cifrar los archivos.

---

## Doble extorsión

Combina:

- Robo de información.
- Cifrado.

Actualmente es el modelo predominante.

---

# Indicadores de compromiso (IOC)

Antes y durante el ataque pueden aparecer distintos indicadores.

## Sistema

- Alto uso de disco.
- Alto uso de CPU.
- Lentitud repentina.
- Archivos inaccesibles.
- Cambios masivos de extensiones.
- Aparición de notas de rescate.

---

## Red

- Gran volumen de tráfico saliente.
- Conexiones hacia direcciones IP desconocidas.
- Acceso a múltiples recursos compartidos.
- Accesos SMB inusuales.

---

## Archivos

- Extensiones desconocidas.
- Archivos renombrados.
- Archivos cifrados.
- Notas de rescate (README, HOW_TO_DECRYPT, RECOVER_FILES, etc.).

---

## Seguridad

- Defender deshabilitado.
- Antivirus detenido.
- Eliminación de eventos.
- Shadow Copies eliminadas.
- Servicios detenidos.

---

# Archivos y componentes afectados

Durante la investigación suelen revisarse:

```
C:\Users\
```

```
C:\ProgramData
```

```
C:\Windows\Temp
```

```
C:\Windows\System32
```

```
C:\Windows\Tasks
```

También deben revisarse:

- Recursos compartidos.
- Servidores de archivos.
- NAS.
- Servidores virtuales.
- Copias de seguridad.

---

# Herramientas utilizadas

## Windows

- Microsoft Defender
- Event Viewer
- PowerShell
- CMD
- Administrador de tareas

## Sysinternals

- Process Explorer
- Autoruns
- TCPView
- Procmon
- PsExec
- Sigcheck

## Herramientas externas

- VirusTotal
- Any.Run
- Hybrid Analysis
- ID Ransomware
- NoMoreRansom
- Velociraptor
- YARA

---

# Impacto

Una infección por ransomware puede provocar:

- Interrupción completa del negocio.
- Pérdida de disponibilidad.
- Fuga de información.
- Pérdida económica.
- Incumplimiento normativo.
- Daño reputacional.

---

# ¿Debe pagarse el rescate?

Desde un punto de vista técnico y de ciberseguridad, **no se recomienda pagar el rescate**.

Pagar no garantiza:

- La recuperación de los datos.
- Que no existan puertas traseras.
- Que los datos robados sean eliminados.
- Que el atacante no vuelva a comprometer la organización.

La prioridad debe centrarse en:

- Contener el incidente.
- Erradicar la amenaza.
- Restaurar desde copias de seguridad verificadas.
- Investigar el acceso inicial.

---

# Medidas preventivas

Las principales medidas para reducir el riesgo son:

- Mantener Windows actualizado.
- Utilizar MFA.
- Limitar privilegios administrativos.
- Deshabilitar protocolos inseguros.
- Segmentar la red.
- Monitorizar eventos de seguridad.
- Proteger RDP y VPN.
- Mantener copias de seguridad offline.
- Verificar periódicamente las copias de seguridad.
- Formar a los usuarios frente al phishing.

---

# Respuesta ante un ransomware

Ante una sospecha de ransomware, el orden de actuación recomendado es:

1. Confirmar la infección.
2. Aislar inmediatamente el equipo afectado.
3. Evitar su propagación a otros sistemas.
4. Identificar el alcance del incidente.
5. Preservar evidencias.
6. Analizar el tipo de ransomware.
7. Comprobar la existencia de copias de seguridad.
8. Restaurar los sistemas afectados.
9. Investigar el acceso inicial.
10. Documentar el incidente.

Estas acciones se desarrollarán de forma práctica en el archivo `Playbook.yaml`.

---

# Relación con otros incidentes

Una infección por ransomware suele estar relacionada con otros playbooks del repositorio:

- **03 - Phishing** (vector de entrada más frecuente).
- **04 - Malware** (fase previa al cifrado).
- **02 - Contraseña Comprometida** (uso de credenciales robadas).
- **14 - Active Directory** (movimiento lateral y escalada de privilegios).
- **16 - NAS** (cifrado de recursos compartidos).
- **17 - Backups** (restauración de la información).
- **18 - Correo** (campañas de phishing o robo de credenciales).

En la mayoría de los casos, una respuesta eficaz al ransomware requerirá ejecutar varios playbooks de forma coordinada.