# Configuración de Jenkins para Despliegue Automático

Este documento describe cómo configurar Jenkins para desplegar automáticamente el proyecto con Docker y HTTPS.

## Requisitos Previos en el Servidor Jenkins

1. **Docker Desktop** o **Docker Engine** instalado y corriendo
2. **Docker Compose** instalado (v2.0 o superior)
3. **OpenSSL** o **Git for Windows** (para generar certificados SSL)
4. **PowerShell** (incluido en Windows)

## Configuración de Jenkins

### 1. Instalar Plugins Necesarios

Asegúrate de tener instalados los siguientes plugins en Jenkins:

- **Pipeline** (generalmente viene por defecto)
- **Docker Pipeline** (opcional, pero recomendado)
- **Git** (para clonar el repositorio)

### 2. Configurar Credenciales (si es necesario)

Si tu repositorio es privado, configura las credenciales de Git en Jenkins:

1. Ve a **Manage Jenkins** → **Manage Credentials**
2. Agrega las credenciales de tu repositorio Git

### 3. Crear un Pipeline Job

1. En Jenkins, haz clic en **New Item**
2. Ingresa un nombre para el job (ej: `SGU-AGJA-10A`)
3. Selecciona **Pipeline**
4. Haz clic en **OK**

### 4. Configurar el Pipeline

En la configuración del job:

1. **Pipeline Definition**: Selecciona **Pipeline script from SCM**
2. **SCM**: Selecciona **Git**
3. **Repository URL**: Ingresa la URL de tu repositorio Git
4. **Credentials**: Selecciona las credenciales si el repo es privado
5. **Branch Specifier**: `*/main` o `*/master` (según tu rama principal)
6. **Script Path**: `Jenkinsfile` (debe estar en la raíz del repositorio)

### 5. Configurar Variables de Entorno (Opcional)

Si necesitas personalizar la ruta de los certificados:

1. En la configuración del job, ve a **Build Environment**
2. Marca **Use secret text(s) or file(s)**
3. Agrega una variable de entorno `CERT_PATH` si es necesario

## Estructura del Pipeline

El `Jenkinsfile` ejecuta los siguientes pasos:

1. **Obteniendo código del repositorio**: Clona/actualiza el código desde Git
2. **Verificando certificados SSL**: Verifica si existen certificados, si no los crea automáticamente
3. **Creando volúmenes y redes Docker**: Crea los recursos Docker necesarios
4. **Deteniendo servicios previos**: Detiene contenedores existentes
5. **Limpiando imágenes anteriores**: Elimina imágenes antiguas para forzar reconstrucción
6. **Construyendo y desplegando servicios**: Construye las imágenes y levanta los contenedores
7. **Verificando estado de los servicios**: Muestra el estado final de los contenedores

## Primera Ejecución

En la primera ejecución, el pipeline:

1. Clonará el repositorio
2. Creará los certificados SSL automáticamente (si no existen)
3. Creará los volúmenes y redes Docker
4. Construirá las imágenes desde cero
5. Iniciará todos los servicios

**Nota**: La primera ejecución puede tardar varios minutos debido a la descarga de dependencias y construcción de imágenes.

## Ejecuciones Subsecuentes

En ejecuciones posteriores:

1. Actualizará el código desde Git
2. Verificará los certificados (no los recreará si ya existen)
3. Reconstruirá las imágenes con los cambios más recientes
4. Reiniciará los servicios

## Verificación del Despliegue

Después de una ejecución exitosa, puedes verificar:

1. **Estado de los contenedores**:
   ```powershell
   docker compose ps
   ```

2. **Logs de los servicios**:
   ```powershell
   docker compose logs -f
   ```

3. **Acceder a la aplicación**:
   - Frontend: https://localhost
   - Backend API: https://localhost:8081

## Solución de Problemas

### Error: "Certificados no encontrados"

**Solución**: El script `setup-certificates.ps1` se ejecutará automáticamente. Si falla:
- Verifica que OpenSSL esté instalado o que Git for Windows esté en el PATH
- Verifica los permisos de escritura en `C:\etc\letsencrypt`

### Error: "Docker no está corriendo"

**Solución**: 
- Asegúrate de que Docker Desktop esté iniciado
- Verifica que el servicio de Docker esté corriendo

### Error: "Puertos en uso"

**Solución**:
- Verifica que los puertos 80, 443, 8081 y 3307 no estén en uso
- Detén otros servicios que puedan estar usando estos puertos

### Error: "No se pueden crear volúmenes"

**Solución**:
- Verifica los permisos de Docker
- Intenta crear los volúmenes manualmente:
  ```powershell
  docker volume create sgu-volume
  docker volume create certbot-conf
  docker network create sgu-net
  ```

## Configuración Avanzada

### Usar Certificados Existentes

Si ya tienes certificados SSL en otra ubicación:

1. Establece la variable de entorno `CERT_PATH` en Jenkins
2. O modifica el `Jenkinsfile` para usar una ruta diferente

### Despliegue en Múltiples Ambientes

Puedes crear múltiples jobs de Jenkins para diferentes ambientes:

- **Desarrollo**: `SGU-AGJA-10A-dev`
- **Producción**: `SGU-AGJA-10A-prod`

Cada uno puede tener su propia configuración de certificados y puertos.

### Notificaciones

Puedes agregar notificaciones al pipeline (email, Slack, etc.) en la sección `post` del `Jenkinsfile`.

## Comandos Útiles

### Ver logs del último build
```powershell
# En Jenkins, ve a la ejecución del build y haz clic en "Console Output"
```

### Ejecutar manualmente desde Jenkins
1. Ve al job en Jenkins
2. Haz clic en **Build Now**

### Detener servicios manualmente
```powershell
docker compose down
```

### Ver estado de los servicios
```powershell
docker compose ps
```

## Notas Importantes

1. **Certificados SSL**: Los certificados generados son autofirmados y solo son válidos para desarrollo. Para producción, usa certificados de Let's Encrypt o una CA válida.

2. **Persistencia de Datos**: Los datos de la base de datos se almacenan en el volumen `sgu-volume`. Si eliminas este volumen, perderás todos los datos.

3. **Seguridad**: En producción, considera:
   - Usar variables de entorno para contraseñas
   - Configurar firewall apropiadamente
   - Usar certificados SSL válidos
   - Implementar autenticación y autorización

4. **Rendimiento**: La primera construcción puede tardar varios minutos. Las construcciones subsecuentes serán más rápidas gracias al caché de Docker.

