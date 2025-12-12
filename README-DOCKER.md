# Guía de Docker con HTTPS

Este proyecto está configurado para ejecutarse completamente en Docker con soporte HTTPS.

## Requisitos Previos

1. **Docker Desktop** instalado y corriendo
2. **Certificados SSL** instalados en `C:\etc\letsencrypt\live\localhost\`
   - `fullchain.pem`
   - `privkey.pem`
   - `keystore.p12` (para el backend Spring Boot)

## Estructura del Proyecto

```
SGU-AGJA-10A-main/
├── client/          # Frontend React con Vite
├── server/          # Backend Spring Boot
├── docker-compose.yml
├── setup.ps1        # Script de inicialización
├── run.ps1          # Script para iniciar
└── stop.ps1         # Script para detener
```

## Configuración Inicial

### 1. Primera vez - Configuración completa

Ejecuta el script de inicialización:

```powershell
.\setup.ps1
```

Este script:
- Verifica que Docker esté instalado y corriendo
- Verifica los certificados SSL
- Crea los volúmenes Docker necesarios
- Crea la red Docker
- Construye las imágenes
- Inicia todos los contenedores

### 2. Ejecutar el proyecto (después de la primera vez)

Si ya ejecutaste `setup.ps1` anteriormente, puedes usar:

```powershell
.\run.ps1
```

O directamente con Docker Compose:

```powershell
docker compose up -d
```

## Servicios Disponibles

Una vez iniciado, los servicios estarán disponibles en:

- **Frontend (HTTPS)**: https://localhost
- **Frontend (HTTP)**: http://localhost (redirige automáticamente a HTTPS)
- **Backend API**: https://localhost:8081
- **Base de datos**: localhost:3307

## Comandos Útiles

### Ver logs de todos los servicios
```powershell
docker compose logs -f
```

### Ver logs de un servicio específico
```powershell
docker compose logs -f frontend
docker compose logs -f backend
docker compose logs -f database
```

### Detener todos los servicios
```powershell
.\stop.ps1
```

O directamente:
```powershell
docker compose down
```

### Reiniciar servicios
```powershell
docker compose restart
```

### Reconstruir imágenes
```powershell
docker compose build --no-cache
docker compose up -d
```

### Ver estado de los contenedores
```powershell
docker compose ps
```

## Configuración de Certificados SSL

### Crear Certificados Automáticamente

El proyecto incluye un script para crear certificados SSL autofirmados automáticamente:

```powershell
.\setup-certificates.ps1
```

Este script:
- Verifica si OpenSSL está instalado (busca en Git si no está en el PATH)
- Verifica si los certificados ya existen
- Crea certificados autofirmados si no existen
- Genera el keystore necesario para Spring Boot

**Nota**: Los certificados autofirmados generarán una advertencia de seguridad en el navegador. Esto es normal para desarrollo local. Para producción, usa certificados de Let's Encrypt o una CA válida.

### Ubicación de los Certificados

Los certificados SSL deben estar en:
```
C:\etc\letsencrypt\live\localhost\
├── fullchain.pem
├── privkey.pem
└── keystore.p12
```

**Nota**: Si tus certificados están en otra ubicación, puedes establecer la variable de entorno `CERT_PATH` antes de ejecutar los scripts:

```powershell
$env:CERT_PATH = "C:\ruta\a\tus\certificados"
.\setup.ps1
```

Los certificados se montan directamente desde el host usando bind mount, por lo que cualquier cambio en los certificados se reflejará automáticamente en los contenedores.

### El script `setup.ps1` crea certificados automáticamente

Si ejecutas `.\setup.ps1` y los certificados no existen, el script automáticamente ejecutará `setup-certificates.ps1` para crearlos.

## Arquitectura

```
┌─────────────────┐
│   Frontend      │  Nginx con SSL
│   (Puerto 443)  │  ──────────────┐
└─────────────────┘                 │
                                    │ Proxy /api/*
┌─────────────────┐                 │
│   Backend        │  Spring Boot   │
│   (Puerto 8080)  │  con SSL       │
└─────────────────┘                 │
                                    │
┌─────────────────┐                 │
│   Database      │  MySQL 8        │
│   (Puerto 3306) │                 │
└─────────────────┘                 │
```

## Solución de Problemas

### Los contenedores no inician

1. Verifica que Docker Desktop esté corriendo
2. Verifica que los puertos 80, 443, 8081 y 3307 no estén en uso
3. Revisa los logs: `docker compose logs`

### Error de certificados SSL

1. Verifica que los certificados existan en `C:\etc\letsencrypt\live\localhost\`
2. Verifica los permisos de los archivos de certificados
3. Asegúrate de que el keystore.p12 tenga la contraseña correcta (por defecto: `changeit`)

### El frontend no puede conectar con el backend

1. Verifica que el backend esté corriendo: `docker compose ps`
2. Revisa los logs del backend: `docker compose logs backend`
3. Verifica que nginx esté configurado correctamente para hacer proxy

### La base de datos no conecta

1. Verifica que el contenedor de la base de datos esté corriendo
2. Revisa los logs: `docker compose logs database`
3. Verifica las variables de entorno en `docker-compose.yml`

## Limpieza

Para eliminar todo (contenedores, volúmenes, redes):

```powershell
docker compose down -v
docker volume rm sgu-volume certbot-conf
docker network rm sgu-net
```

**⚠️ ADVERTENCIA**: Esto eliminará todos los datos de la base de datos.

