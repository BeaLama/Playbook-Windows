# Teoría - DNS

## Introducción

El Sistema de Nombres de Dominio (DNS, Domain Name System) es uno de los servicios fundamentales de cualquier red. Su función principal es traducir nombres de dominio legibles por las personas (como `google.com`) en direcciones IP que los dispositivos utilizan para comunicarse.

Sin DNS, los usuarios tendrían que recordar la dirección IP de cada servicio al que desean acceder.

Debido a su importancia, un fallo en el servicio DNS puede impedir el acceso a páginas web, aplicaciones corporativas, servidores internos, recursos compartidos e incluso impedir el inicio de sesión en un dominio de Active Directory.

---

# ¿Qué es DNS?

DNS es un sistema distribuido y jerárquico encargado de resolver nombres de dominio.

Cuando un usuario escribe una dirección como:

```
www.microsoft.com
```

el equipo consulta un servidor DNS para averiguar la dirección IP correspondiente.

Ejemplo:

```
www.microsoft.com
↓

13.107.246.38
```

Posteriormente, el equipo establece la comunicación utilizando esa dirección IP.

---

# Funcionamiento del DNS

Cuando un usuario solicita un dominio, el proceso de resolución sigue varias etapas.

```text
Usuario

     │

     ▼

Cache DNS local

     │

     ▼

Servidor DNS configurado

     │

     ▼

Servidor Root

     │

     ▼

Servidor TLD (.com, .es...)

     │

     ▼

Servidor Autoritativo

     │

     ▼

Dirección IP

     │

     ▼

Cliente
```

Si el servidor DNS ya conoce la respuesta, devolverá la dirección IP directamente sin consultar el resto de servidores.

---

# Componentes principales

## Cliente DNS

Es el dispositivo que realiza la consulta.

Ejemplos:

- Windows
- Linux
- Teléfono móvil
- Servidor

---

## Servidor DNS

Responde las consultas realizadas por los clientes.

Puede ser:

- DNS corporativo
- DNS del ISP
- DNS público
- DNS interno

---

## Servidores Root

Son el nivel superior del sistema DNS.

No conocen la IP del dominio solicitado, pero indican qué servidor debe consultarse a continuación.

---

## Servidores TLD

Gestionan dominios como:

```
.com
.es
.net
.org
```

---

## Servidores Autoritativos

Contienen la información definitiva de un dominio.

Son los responsables de responder con la dirección IP correcta.

---

# Tipos de consultas DNS

## Consulta recursiva

El cliente solicita la resolución completa.

El servidor DNS obtiene la respuesta por él.

Es la consulta más habitual.

---

## Consulta iterativa

El servidor responde indicando qué servidor consultar a continuación.

Es utilizada principalmente entre servidores DNS.

---

# Registros DNS

Los registros almacenan la información asociada a un dominio.

## A

Relaciona un nombre con una dirección IPv4.

Ejemplo:

```
empresa.local

↓

192.168.1.20
```

---

## AAAA

Relaciona un nombre con una dirección IPv6.

---

## CNAME

Crea un alias hacia otro nombre DNS.

Ejemplo:

```
www

↓

servidor-web
```

---

## MX

Indica qué servidor recibe el correo electrónico de un dominio.

---

## NS

Define los servidores autoritativos del dominio.

---

## PTR

Permite realizar resolución inversa.

IP → Nombre

---

## TXT

Almacena información adicional.

Muy utilizado para:

- SPF
- DKIM
- DMARC
- Verificaciones de dominio

---

## SRV

Muy utilizado por Active Directory.

Permite localizar servicios como:

- LDAP
- Kerberos
- Global Catalog

---

# Caché DNS

Windows almacena temporalmente las respuestas DNS para acelerar futuras consultas.

Puede visualizarse mediante:

```cmd
ipconfig /displaydns
```

Y vaciarse mediante:

```cmd
ipconfig /flushdns
```

---

# Problemas habituales

Las incidencias DNS más comunes son:

- No resuelve nombres.
- Resolución lenta.
- DNS incorrecto.
- Caché corrupta.
- Servidor DNS caído.
- Zona DNS mal configurada.
- Registro eliminado.
- Problemas de replicación en Active Directory.

---

# Síntomas

Un problema DNS puede provocar:

- No abre páginas web.
- No se localizan servidores.
- Error al iniciar sesión en dominio.
- Recursos compartidos inaccesibles.
- Outlook no conecta.
- VPN funciona parcialmente.
- Solo funciona utilizando direcciones IP.

---

# Herramientas de diagnóstico

## Windows

- nslookup
- ipconfig
- ping
- tracert
- Resolve-DnsName
- Test-NetConnection
- Get-DnsClientServerAddress

---

## Linux

- dig
- host
- nslookup
- resolvectl
- ping
- traceroute

---

# Comandos habituales

## Ver servidores DNS

```powershell
Get-DnsClientServerAddress
```

---

## Consultar un dominio

```cmd
nslookup google.com
```

---

## Vaciar la caché DNS

```cmd
ipconfig /flushdns
```

---

## Mostrar la caché

```cmd
ipconfig /displaydns
```

---

## Resolver mediante PowerShell

```powershell
Resolve-DnsName microsoft.com
```

---

## Probar un servidor DNS concreto

```cmd
nslookup google.com 8.8.8.8
```

---

# DNS en Active Directory

DNS es un componente esencial en Active Directory.

Sin DNS correctamente configurado pueden aparecer problemas como:

- Usuarios que no pueden iniciar sesión.
- Equipos que no encuentran el controlador de dominio.
- Errores de replicación.
- Fallos en Kerberos.
- Problemas con GPO.

Por este motivo, en un dominio Windows los clientes deben utilizar como servidor DNS el controlador de dominio o los servidores DNS autorizados de la organización.

---

# Buenas prácticas

Se recomienda:

- Utilizar servidores DNS redundantes.
- Supervisar la disponibilidad del servicio.
- Realizar copias de seguridad de las zonas DNS.
- Revisar periódicamente los registros obsoletos.
- Limitar las transferencias de zona.
- Habilitar DNSSEC cuando sea posible.
- Utilizar registros PTR correctamente configurados.
- Evitar configurar manualmente DNS públicos en equipos unidos al dominio.

---

# Procedimiento general

Ante una incidencia DNS, el orden recomendado es:

1. Confirmar el síntoma.
2. Comprobar la conectividad IP.
3. Verificar la configuración DNS del cliente.
4. Probar la resolución mediante `nslookup`.
5. Revisar la caché DNS.
6. Comprobar el servidor DNS.
7. Revisar los registros necesarios.
8. Validar el funcionamiento del servicio.

El procedimiento detallado se desarrollará en el archivo `Playbook.yaml`.

---

# Relación con otros incidentes

Las incidencias DNS suelen estar relacionadas con otros playbooks del repositorio.

- **10 - Sin Internet**
- **12 - DHCP**
- **13 - VPN**
- **14 - Active Directory**
- **16 - NAS**
- **18 - Correo**

En muchos casos, un problema aparentemente relacionado con Internet o con Active Directory tiene su origen en una configuración DNS incorrecta o en un fallo del servicio de resolución de nombres.