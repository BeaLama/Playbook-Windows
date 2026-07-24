# 📘 Playbook Profesional de Respuesta ante Incidentes IT

> Guía técnica para la detección, análisis, contención, erradicación, recuperación y documentación de incidentes en infraestructuras informáticas.

---

# Índice

- [Objetivo](#objetivo)
- [Alcance](#alcance)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Cómo usar este repositorio](#cómo-usar-este-repositorio)
- [Flujo de trabajo](#flujo-de-trabajo)
- [Clasificación de incidencias](#clasificación-de-incidentes)
- [Buenas prácticas](#buenas-prácticas)
- [Requisitos](#requisitos)
- [Estado del proyecto](#estado-del-proyecto)
- [Licencia](#licencia)

---

# Objetivo

Este repositorio tiene como finalidad servir como guía de referencia para la gestión de incidencias en entornos corporativos.

Su propósito es proporcionar procedimientos claros, estructurados y repetibles que permitan identificar, investigar, contener, resolver y documentar incidentes tecnológicos de forma eficiente.

Este playbook no está orientado únicamente a resolver problemas, sino también a estandarizar la actuación del personal de soporte y administración de sistemas, reduciendo los tiempos de respuesta y facilitando la mejora continua de los procesos.

# Alcance

La documentación está orientada principalmente a infraestructuras Microsoft Windows, aunque muchos de los procedimientos son extrapolables a otros entornos.

Incluye procedimientos relacionados con:

- Equipos cliente Windows
- Windows Server
- Active Directory
- DNS
- DHCP
- VPN
- Redes corporativas
- Impresoras
- Servicios de correo electrónico
- Copias de seguridad
- Malware
- Ransomware
- Phishing
- Gestión de usuarios

---

# Estructura del proyecto

```
Playbook-Respuesta-Incidentes/
│
├── README.md
│
├── 00-Metodologia/
│   └── Metodologia.md          ← Estándar de TASK, formato y clasificación (leer primero)
│
├── 01-Usuario-Bloqueado/
│   ├── Teoria.md
│   ├── Playbook.md
│   └── Scripts/
│
├── 02-Contrasena-Comprometida/
├── 03-Phishing/
├── 04-Malware/
├── 05-Ransomware/
├── 06-DNS/
├── 07-DHCP/
├── 08-VPN/
├── 09-Active-Directory/
├── 10-Impresoras/
├── 11-Backups/
└── 12-Correo/

```

Cada carpeta de incidente sigue exactamente el mismo patrón interno:

```
NN-Nombre-Incidente/
├── Teoria.md      → Conceptos mínimos (se lee una vez, fuera de la incidencia real)
├── Playbook.md    → Procedimiento operativo (lo único que se abre durante la incidencia)
└── Scripts/       → Scripts referenciados desde el Playbook
```

---

# Cómo usar este repositorio

1. **La primera vez**, lee `00-Metodologia/Metodologia.md`. Define cómo está construida cada TASK y cómo interpretar los árboles de decisión. Se lee una única vez.
2. **Durante una incidencia real**, entra directamente en la carpeta del incidente y abre `Playbook.md`. No leas `Teoria.md` en caliente — está pensado para formación, no para consulta bajo presión de tiempo.
3. Sigue las TASK en orden, siguiendo las decisiones indicadas en cada una. Cada TASK te dirá explícitamente a qué otra TASK ir, o a qué otro playbook (`INC-XXX`) derivar si el diagnóstico cambia de naturaleza.
4. Ejecuta los scripts de la carpeta `Scripts/` cuando el Playbook los referencie — no los ejecutes preventivamente ni fuera del contexto de la TASK que los invoca.
5. Cierra siempre el incidente siguiendo el checklist de la última TASK, adjuntando las evidencias indicadas.

---

# Flujo de trabajo

Todos los incidentes siguen el siguiente flujo general (detallado por TASK dentro de cada `Playbook.md`):

```text
Recepción del incidente
          │
          ▼
Identificación
          │
          ▼
Clasificación
          │
          ▼
Priorización
          │
          ▼
Recogida de evidencias
          │
          ▼
Diagnóstico
          │
          ▼
Contención
          │
          ▼
Erradicación
          │
          ▼
Recuperación
          │
          ▼
Verificación
          │
          ▼
Documentación
          │
          ▼
Lecciones aprendidas
```

---

# Clasificación de incidentes

Los incidentes se clasifican según su impacto sobre el negocio. Cada `Playbook.md` declara una criticidad por defecto, reclasificable según el contexto real.

| Nivel | Descripción | Tiempo objetivo |
|--------|-------------|-----------------|
| 🔴 Crítico | Interrupción total del servicio | Inmediato |
| 🟠 Alto | Afecta a varios usuarios o servicios importantes | < 1 hora |
| 🟡 Medio | Afecta a un usuario o servicio no crítico | < 4 horas |
| 🟢 Bajo | Incidencia menor o consulta | Según planificación |

---

# Buenas prácticas

Durante toda la gestión de incidentes se seguirán los siguientes principios:

- Mantener la integridad de las evidencias.
- Documentar todas las actuaciones realizadas.
- Minimizar el impacto sobre el usuario.
- Aplicar el principio de mínimo privilegio.
- Priorizar la continuidad del negocio.
- Evitar modificaciones innecesarias durante la investigación.
- Validar siempre la resolución antes de cerrar el incidente.
- Registrar las lecciones aprendidas.

---

# Requisitos

Para seguir correctamente esta documentación se recomienda disponer de conocimientos básicos sobre:

- Windows
- Redes TCP/IP
- DNS
- DHCP
- Active Directory
- PowerShell
- CMD
- Administración de sistemas
- Virtualización (opcional)

---

# Estado del proyecto

🚧 En desarrollo

| Incidente | Estado |
|---|---|
| 00-Metodologia | ✅ Completo |
| 01-Usuario-Bloqueado | ✅ Completo |
| 02-Contrasena-Comprometida → 18-Correo | 🚧 Pendiente de desarrollo |

Este playbook se encuentra en continua evolución. Se irán incorporando nuevos procedimientos, herramientas, casos prácticos y mejoras conforme se amplíe la documentación y la experiencia operativa.

---

# Licencia

Este proyecto tiene fines educativos, formativos y de estandarización de procedimientos técnicos.

Cada organización deberá adaptar los procedimientos descritos a su infraestructura, políticas internas y requisitos de seguridad.

---

# Autor

**Beatriz Lama**

Auxiliar Técnico IT | Administración de Sistemas | Ciberseguridad | Automatización | Documentación Técnica
