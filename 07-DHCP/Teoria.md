# Teoría - DHCP

## Introducción

El Dynamic Host Configuration Protocol (DHCP) es un protocolo de red cuya función es asignar automáticamente la configuración IP a los dispositivos conectados a una red.

Gracias a DHCP, los administradores no necesitan configurar manualmente cada equipo, reduciendo errores y simplificando la gestión de redes.

Además de la dirección IP, DHCP puede proporcionar otros parámetros esenciales como la máscara de subred, la puerta de enlace predeterminada, los servidores DNS o el nombre de dominio.

---

# ¿Qué es DHCP?

DHCP (Dynamic Host Configuration Protocol) es un protocolo cliente-servidor que automatiza la asignación de parámetros de red.

Cuando un equipo se conecta a una red configurada con DHCP, solicita automáticamente una configuración válida al servidor DHCP.

Si el servidor responde correctamente, el cliente recibe toda la información necesaria para comunicarse con el resto de dispositivos.

---

# Parámetros que puede proporcionar DHCP

Un servidor DHCP puede asignar:

- Dirección IP.
- Máscara de subred.
- Puerta de enlace predeterminada.
- Servidores DNS.
- Nombre de dominio.
- Tiempo de concesión (Lease Time).
- Servidores NTP.
- Servidores WINS (entornos antiguos).
- Opciones específicas para determinados dispositivos.

---

# Funcionamiento del protocolo

El proceso de obtención de una dirección IP consta de cuatro fases, conocidas como **DORA**.

```text
Cliente
   │
   │ DHCP Discover
   ▼
Servidor DHCP
   │
   │ DHCP Offer
   ▼
Cliente
   │
   │ DHCP Request
   ▼
Servidor DHCP
   │
   │ DHCP Acknowledgement (ACK)
   ▼
Cliente configurado
```

## DHCP Discover

El cliente envía un mensaje de difusión (Broadcast) buscando servidores DHCP disponibles.

---

## DHCP Offer

Uno o varios servidores responden ofreciendo una dirección IP disponible.

---

## DHCP Request

El cliente selecciona una de las ofertas y solicita utilizar esa configuración.

---

## DHCP ACK

El servidor confirma la asignación y reserva temporalmente la dirección IP para ese cliente.

---

# Componentes del servicio

## Cliente DHCP

Equipo que solicita una configuración de red.

Ejemplos:

- Windows
- Linux
- Servidores
- Impresoras
- Teléfonos IP

---

## Servidor DHCP

Gestiona los rangos de direcciones disponibles y asigna la configuración a los clientes.

Puede estar integrado en:

- Windows Server
- Linux
- Routers
- Firewalls
- Appliances de red

---

## Ámbito (Scope)

Es el rango de direcciones IP que el servidor puede asignar.

Ejemplo:

```
192.168.1.100

↓

192.168.1.200
```

---

## Reserva

Permite asignar siempre la misma dirección IP a un dispositivo mediante su dirección MAC.

Muy utilizado para:

- Servidores.
- Impresoras.
- NAS.
- Cámaras IP.
- Equipos de red.

---

## Exclusión

Direcciones que el servidor nunca asignará automáticamente.

Ejemplo:

```
192.168.1.1
192.168.1.2
192.168.1.10
```

---

# Tiempo de concesión (Lease)

La dirección IP asignada no es permanente.

Cada cliente dispone de un tiempo de concesión durante el cual puede utilizar esa dirección.

Cuando el tiempo está próximo a finalizar, el cliente solicita su renovación automáticamente.

---

# Puertos utilizados

DHCP utiliza el protocolo UDP.

| Servicio | Puerto |
|----------|--------|
| Cliente DHCP | UDP 68 |
| Servidor DHCP | UDP 67 |

---

# Problemas habituales

Las incidencias más frecuentes relacionadas con DHCP son:

- El cliente no obtiene dirección IP.
- Dirección APIPA (169.254.x.x).
- Ámbito agotado.
- Servidor DHCP detenido.
- Reserva incorrecta.
- Conflictos de direcciones IP.
- Múltiples servidores DHCP en la misma red.
- Configuración incorrecta del Relay DHCP.

---

# Dirección APIPA

Cuando un cliente no consigue contactar con un servidor DHCP, Windows asigna automáticamente una dirección:

```
169.254.x.x
```

Esto indica normalmente un problema de comunicación con el servidor DHCP o la ausencia de este.

---

# Síntomas

Una incidencia DHCP puede provocar:

- Sin acceso a Internet.
- Dirección IP incorrecta.
- Dirección APIPA.
- No localiza el dominio.
- No encuentra recursos compartidos.
- Errores de autenticación.
- Conectividad intermitente.

---

# Herramientas de diagnóstico

## Windows

- ipconfig
- Get-NetIPConfiguration
- Get-DhcpServerv4Scope (Windows Server)
- Get-DhcpServerv4Lease
- Test-NetConnection
- Event Viewer

---

## Linux

- ip addr
- dhclient
- nmcli
- journalctl
- systemctl
- tcpdump

---

# Comandos habituales

## Mostrar configuración IP

```cmd
ipconfig /all
```

---

## Liberar dirección IP

```cmd
ipconfig /release
```

---

## Renovar dirección IP

```cmd
ipconfig /renew
```

---

## Ver configuración de red

```powershell
Get-NetIPConfiguration
```

---

## Ver ámbitos DHCP (Windows Server)

```powershell
Get-DhcpServerv4Scope
```

---

## Ver concesiones

```powershell
Get-DhcpServerv4Lease
```

---

# DHCP en Active Directory

En entornos con Active Directory, los servidores DHCP deben estar autorizados en el dominio.

Esto evita que un servidor DHCP no autorizado entregue direcciones IP a los clientes.

Un servidor DHCP no autorizado no comenzará a distribuir direcciones dentro del dominio.

---

# Buenas prácticas

Se recomienda:

- Configurar exclusiones para dispositivos críticos.
- Utilizar reservas para servidores e impresoras.
- Supervisar el porcentaje de uso del ámbito.
- Configurar tiempos de concesión adecuados.
- Implementar alta disponibilidad cuando sea posible.
- Autorizar correctamente los servidores DHCP en Active Directory.
- Documentar todos los ámbitos y reservas.

---

# Procedimiento general

Ante una incidencia DHCP, el orden recomendado es:

1. Confirmar el síntoma.
2. Verificar la configuración IP del cliente.
3. Comprobar si el cliente obtiene una dirección APIPA.
4. Renovar la concesión DHCP.
5. Comprobar la conectividad con el servidor DHCP.
6. Revisar el estado del servicio DHCP.
7. Verificar el ámbito y las concesiones.
8. Confirmar la resolución del problema.

El procedimiento operativo detallado se desarrollará en el archivo `Playbook.yaml`.

---

# Relación con otros incidentes

Las incidencias DHCP suelen estar relacionadas con otros playbooks del repositorio.

- **10 - Sin Internet**
- **11 - DNS**
- **13 - VPN**
- **14 - Active Directory**
- **15 - Impresoras**

En muchos casos, un problema aparentemente relacionado con la conectividad tiene su origen en una configuración DHCP incorrecta o en un fallo del servidor encargado de asignar direcciones IP.