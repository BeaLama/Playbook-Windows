# INC-001 — Usuario Bloqueado · Teoría

> Lectura única. Este documento NO se usa durante la incidencia. Para el procedimiento operativo, ir a [`Playbook.md`](./Playbook.md).

---

## 1. ¿Qué es un "bloqueo de cuenta" en Active Directory?

Un bloqueo (*account lockout*) es un mecanismo defensivo de Active Directory que deshabilita temporalmente el inicio de sesión de una cuenta tras superar un número de intentos fallidos de autenticación, definido por la **Directiva de bloqueo de cuentas** (Account Lockout Policy) del dominio.

Tres parámetros de GPO controlan el comportamiento:

| Parámetro | Descripción | Valor típico |
|---|---|---|
| `Lockout threshold` | Nº de intentos fallidos antes de bloquear | 5–10 |
| `Lockout duration` | Minutos que dura el bloqueo antes de autodesbloquearse | 15–30 min (0 = requiere desbloqueo manual) |
| `Lockout observation window` | Ventana de tiempo en la que se cuentan los fallos | 15–30 min |

Estos valores se consultan con:

```powershell
Get-ADDefaultDomainPasswordPolicy
```

**Importante:** un bloqueo NO es lo mismo que:
- Cuenta **deshabilitada** (`Enabled = $false`) — deshabilitación administrativa manual.
- Cuenta con **contraseña caducada** (`PasswordExpired = $true`) — el usuario puede autenticar pero se le fuerza a cambiarla.
- Cuenta **expirada** (`AccountExpirationDate`) — fecha de validez de la cuenta superada.

El `Playbook.md` distingue estos casos en la TASK-01, porque cada uno deriva a un procedimiento distinto.

---

## 2. Replicación del atributo de bloqueo entre controladores de dominio

El atributo `lockoutTime` de un objeto de usuario **no se replica igual que el resto de atributos**. Cuando un DC bloquea una cuenta, notifica inmediatamente (fuera del ciclo normal de replicación) al **PDC Emulator** del dominio, que es el controlador autoritativo para el estado de bloqueo.

Esto tiene una implicación operativa crítica: **si consultas el estado de bloqueo en un DC que no sea el PDC Emulator, o antes de que la replicación urgente se complete, puedes obtener información desactualizada.**

Para identificar el PDC Emulator del dominio:

```powershell
Get-ADDomain | Select-Object PDCEmulator
```

El `Playbook.md` siempre indica consultar el PDC Emulator como fuente de verdad.

---

## 3. Dónde queda registro del bloqueo (Event IDs relevantes)

| Event ID | Log | Significado |
|---|---|---|
| **4740** | Security (en el DC, normalmente el PDC Emulator) | Se ha bloqueado una cuenta de usuario. Incluye el **equipo de origen** (`Caller Computer Name`) que provocó el bloqueo — dato clave para diagnóstico. |
| **4625** | Security (en el DC o en el equipo local) | Fallo de inicio de sesión. Precede normalmente a los 4740. |
| **4771** | Security (en el DC) | Fallo de pre-autenticación Kerberos. |
| **4776** | Security (en el DC) | Intento de validación de credenciales NTLM (fallido o correcto). |

El campo **`Caller Computer Name`** del evento 4740 es el dato más valioso: identifica **desde qué equipo** se originaron los intentos fallidos que causaron el bloqueo. Esto permite diferenciar entre:

- Un error humano del propio usuario (contraseña cambiada recientemente, Bloq Mayús activado, etc.).
- Un **dispositivo con credenciales cacheadas obsoletas** (móvil, tablet, unidad de red mapeada, tarea programada, servicio Windows) que reintenta automáticamente con la contraseña antigua.
- Un **ataque de fuerza bruta o password spraying**, especialmente si el `Caller Computer Name` es un equipo desconocido, un servidor con múltiples cuentas bloqueadas en poco tiempo, o si el patrón afecta a muchos usuarios simultáneamente.

---

## 4. Causas más frecuentes de bloqueo (orientan la TASK de causa raíz)

1. **Credenciales cacheadas obsoletas** tras un cambio de contraseña: móviles con ActiveSync/Exchange, unidades de red mapeadas con credenciales guardadas en el Administrador de credenciales de Windows, tareas programadas o servicios ejecutándose con una cuenta de usuario.
2. **Error humano repetido**: Bloq Mayús activo, teclado con distribución incorrecta, o el usuario prueba varias contraseñas antiguas.
3. **Sesiones RDP o VPN persistentes** que reintentan con la contraseña anterior tras un cambio.
4. **Ataque activo**: password spraying o fuerza bruta dirigido, visible como múltiples 4740/4625 desde el mismo origen o contra múltiples cuentas.
5. **Replicación/latencia de AD** en entornos multi-sitio con vínculos WAN lentos, que puede producir bloqueos "fantasma" ya resueltos en otro DC.

---

## 5. Por qué esto NO es un playbook de seguridad "per se"

Un usuario bloqueado es, en la mayoría de los casos, un incidente **operativo de bajo impacto**. Sin embargo, el `Playbook.md` incluye un punto de decisión explícito para escalar a **INC-002 (Contraseña comprometida)** cuando el patrón de bloqueo sugiere actividad maliciosa. Confundir ambos escenarios es el error más común de un técnico junior: desbloquear mecánicamente una cuenta bajo ataque activo sin investigar el origen solo le da al atacante más intentos.
