# 00 — Metodología del Playbook

> Este documento define el **estándar operativo** que sigue cada carpeta de incidente del repositorio. Todo `Playbook.md` hereda este formato. No se repite en cada incidente para evitar duplicidad y desincronización de criterios.

---

## 1. Estructura de cada incidente

Cada incidente (`NN-Nombre-Incidente/`) contiene:

```
NN-Nombre-Incidente/
├── Teoria.md      → Conceptos mínimos necesarios para entender el incidente.
│                    NO contiene procedimiento. Se lee UNA vez, no durante la incidencia.
├── Playbook.md    → Procedimiento operativo. Es lo único que se abre durante
│                    una incidencia real. Cero teoría, solo TASKs y decisiones.
└── Scripts/       → Scripts referenciados desde el Playbook, listos para ejecutar.
```

**Regla de oro:** si durante una incidencia real un técnico necesita leer un párrafo explicativo para saber qué hacer, el `Playbook.md` está mal escrito. Debe bastar con leer el nombre de la TASK, ejecutar el comando y seguir la decisión.

---

## 2. Anatomía de una TASK

Toda tarea operativa (`TASK-NN`) se documenta con los siguientes campos, en este orden:

| Campo | Contenido |
|---|---|
| **Objetivo** | Qué se intenta confirmar o resolver con esta TASK. Una frase. |
| **Herramientas** | Software/rol necesario (PowerShell, ADUC, Event Viewer, Sysinternals, etc.) |
| **Permisos necesarios** | Grupo/rol mínimo requerido (principio de mínimo privilegio). |
| **Tiempo estimado** | Duración orientativa de la tarea, para gestión de SLA. |
| **Comandos** | Comando literal, copiable y ejecutable. Nunca en prosa. |
| **Resultado esperado** | Qué se debería ver si todo es "normal". |
| **Posibles resultados** | Variantes de salida y qué significa cada una. |
| **Decisión** | Regla explícita: si pasa X → vas a TASK-Y. Si pasa Z → vas a TASK-W o a otro playbook. |
| **Evidencias a guardar** | Qué capturar (export CSV, screenshot, ID de log) y dónde archivarlo (ticket). |

---

## 3. Notación del árbol de decisión

Se usa notación de árbol en texto plano, compatible con cualquier visor Markdown (GitHub, Azure DevOps, GitLab, VS Code):

```text
Pregunta de diagnóstico
          │
   ┌──────┴──────┐
   Sí            No
   │              │
   ▼              ▼
TASK-XX      Ir a Playbook INC-YYY
```

---

## 4. Nomenclatura de incidentes (IDs)

Cada carpeta corresponde a un identificador de incidente interno usado para referencias cruzadas entre playbooks:

| ID | Carpeta |
|---|---|
| INC-001 | 01-Usuario-Bloqueado |
| INC-002 | 02-Contrasena-Comprometida |
| INC-003 | 03-Phishing |
| INC-004 | 04-Malware |
| INC-005 | 05-Ransomware |
| INC-006 | 06-Windows-No-Arranca |
| INC-007 | 07-BSOD |
| INC-008 | 08-Disco-Lleno |
| INC-009 | 09-PC-Lento |
| INC-010 | 10-Sin-Internet |
| INC-011 | 11-DNS |
| INC-012 | 12-DHCP |
| INC-013 | 13-VPN |
| INC-014 | 14-Active-Directory |
| INC-015 | 15-Impresoras |
| INC-016 | 16-NAS |
| INC-017 | 17-Backups |
| INC-018 | 18-Correo |

Cuando un `Playbook.md` deriva a otro incidente, se referencia siempre por su ID (`INC-002`), nunca por el nombre de carpeta, para que el enlace sobreviva a un renombrado.

---

## 5. Clasificación de criticidad (heredada del README raíz)

| Nivel | Descripción | SLA objetivo |
|---|---|---|
| 🔴 Crítico | Interrupción total del servicio | Inmediato |
| 🟠 Alto | Afecta a varios usuarios o servicios importantes | < 1 hora |
| 🟡 Medio | Afecta a un usuario o servicio no crítico | < 4 horas |
| 🟢 Bajo | Incidencia menor o consulta | Según planificación |

Cada `Playbook.md` declara su criticidad **por defecto** en la cabecera, pero el técnico puede reclasificarla según el contexto (ej.: un "Usuario Bloqueado" normalmente 🟢/🟡 pasa a 🟠 si es el CEO o un servicio con cuenta compartida).

---

## 6. Principio de evidencias

Toda TASK que modifique estado (desbloquear, reiniciar servicio, borrar archivo, aislar host) debe:

1. Registrarse en el ticket con timestamp UTC y usuario que ejecuta.
2. Guardar la salida del comando (texto o captura) como adjunto.
3. No destruir evidencia previa a la contención en incidentes de tipo seguridad (Malware, Ransomware, Phishing, Contraseña comprometida) — en esos casos, el Playbook indica explícitamente "NO EJECUTAR" antes de ciertas TASKs de erradicación hasta confirmar recogida de evidencias.

---

## 7. Versionado

Cada `Playbook.md` incluye una tabla de control de versiones al final:

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| 1.0 | AAAA-MM-DD | Nombre | Versión inicial |

Cualquier cambio de comando (ej.: cmdlet deprecado en una versión nueva de PowerShell) debe reflejarse aquí, no solo en el cuerpo del documento.
