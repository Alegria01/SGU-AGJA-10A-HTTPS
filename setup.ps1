# Script de inicializacion para Docker con HTTPS
# Este script configura y ejecuta el proyecto completo con Docker

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuracion Docker con HTTPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker esta instalado y corriendo
Write-Host "[1/5] Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "  [OK] Docker encontrado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Docker no esta instalado o no esta en el PATH" -ForegroundColor Red
    exit 1
}

try {
    docker ps | Out-Null
    Write-Host "  [OK] Docker esta corriendo" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Docker no esta corriendo. Por favor inicia Docker Desktop" -ForegroundColor Red
    exit 1
}

# Verificar que Docker Compose esta disponible
Write-Host "[2/5] Verificando Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker compose version
    Write-Host "  [OK] Docker Compose encontrado: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Docker Compose no esta disponible" -ForegroundColor Red
    exit 1
}

# Verificar certificados SSL
Write-Host "[3/5] Verificando certificados SSL..." -ForegroundColor Yellow
$certPath = $env:CERT_PATH
if (-not $certPath) {
    $certPath = "C:\etc\letsencrypt"
}

$certLivePath = Join-Path $certPath "live\localhost"
$fullchain = Join-Path $certLivePath "fullchain.pem"
$privkey = Join-Path $certLivePath "privkey.pem"
$keystore = Join-Path $certLivePath "keystore.p12"

$certificatesExist = $false
if ((Test-Path $fullchain) -and (Test-Path $privkey)) {
    # Verificar validez de los certificados
    $opensslPath = Get-Command openssl -ErrorAction SilentlyContinue
    if (-not $opensslPath) {
        $gitOpenSSL = "C:\Program Files\Git\usr\bin\openssl.exe"
        if (Test-Path $gitOpenSSL) {
            $env:PATH += ";C:\Program Files\Git\usr\bin"
        }
    }
    
    $certInfo = openssl x509 -in $fullchain -noout -dates -ErrorAction SilentlyContinue
    if ($certInfo) {
        Write-Host "  [OK] Certificados SSL encontrados y validos en $certPath" -ForegroundColor Green
        $certificatesExist = $true
    } else {
        Write-Host "  [ADVERTENCIA] Certificados encontrados pero invalidos o corruptos" -ForegroundColor Yellow
    }
}

if (-not $certificatesExist) {
    Write-Host "  [INFO] Certificados no encontrados o invalidos" -ForegroundColor Yellow
    Write-Host "  Ejecutando script de creacion de certificados..." -ForegroundColor Cyan
    Write-Host ""
    
    # Ejecutar script de creacion de certificados
    $certScript = Join-Path $PSScriptRoot "setup-certificates.ps1"
    if (Test-Path $certScript) {
        & $certScript
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "  [ERROR] Error al crear certificados" -ForegroundColor Red
            Write-Host "  Por favor ejecuta manualmente: .\setup-certificates.ps1" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "  [ADVERTENCIA] Script de certificados no encontrado" -ForegroundColor Yellow
        Write-Host "  Por favor ejecuta: .\setup-certificates.ps1" -ForegroundColor Yellow
        Write-Host ""
        $continue = Read-Host "Deseas continuar de todos modos? (s/n)"
        if ($continue -ne "s" -and $continue -ne "S") {
            exit 1
        }
    }
    
    # Verificar nuevamente
    if ((Test-Path $fullchain) -and (Test-Path $privkey)) {
        Write-Host "  [OK] Certificados creados exitosamente" -ForegroundColor Green
        $certificatesExist = $true
    }
}

if ($certificatesExist) {
    if (Test-Path $keystore) {
        Write-Host "  [OK] Keystore encontrado" -ForegroundColor Green
    } else {
        Write-Host "  [ADVERTENCIA] Keystore no encontrado, intentando crearlo..." -ForegroundColor Yellow
        $opensslPath = Get-Command openssl -ErrorAction SilentlyContinue
        if (-not $opensslPath) {
            $gitOpenSSL = "C:\Program Files\Git\usr\bin\openssl.exe"
            if (Test-Path $gitOpenSSL) {
                $env:PATH += ";C:\Program Files\Git\usr\bin"
            }
        }
        
        $keystorePassword = "changeit"
        openssl pkcs12 -export -in $fullchain -inkey $privkey -out $keystore -name "localhost" -password "pass:$keystorePassword" -noiter -nomaciter 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Keystore creado exitosamente" -ForegroundColor Green
        } else {
            Write-Host "  [ADVERTENCIA] No se pudo crear el keystore" -ForegroundColor Yellow
        }
    }
    # Establecer variable de entorno para docker-compose
    $env:CERT_PATH = $certPath
} else {
    Write-Host "  [ERROR] No se pudieron verificar o crear los certificados SSL" -ForegroundColor Red
    Write-Host "  Por favor ejecuta: .\setup-certificates.ps1" -ForegroundColor Yellow
    exit 1
}

# Crear volumenes si no existen
Write-Host "[4/5] Creando volumenes Docker..." -ForegroundColor Yellow
$volumes = @("sgu-volume", "certbot-conf")

foreach ($volume in $volumes) {
    $volumeExists = docker volume ls -q | Select-String -Pattern "^$volume$"
    if ($volumeExists) {
        Write-Host "  [OK] Volumen '$volume' ya existe" -ForegroundColor Green
    } else {
        docker volume create $volume | Out-Null
        Write-Host "  [OK] Volumen '$volume' creado" -ForegroundColor Green
    }
}

# Los certificados se montaran directamente desde el host usando bind mount
Write-Host "  [INFO] Los certificados se montaran desde: $certPath" -ForegroundColor Cyan

# Crear red si no existe
Write-Host "[5/5] Creando red Docker..." -ForegroundColor Yellow
$networkExists = docker network ls -q | Select-String -Pattern "^sgu-net$"
if ($networkExists) {
    Write-Host "  [OK] Red 'sgu-net' ya existe" -ForegroundColor Green
} else {
    docker network create sgu-net | Out-Null
    Write-Host "  [OK] Red 'sgu-net' creada" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Construyendo imagenes Docker..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Construir imagenes
Write-Host "Construyendo imagenes (esto puede tardar varios minutos)..." -ForegroundColor Yellow
docker compose build

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Error al construir las imagenes" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Iniciando contenedores..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Iniciar contenedores
docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Error al iniciar los contenedores" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  [OK] Proyecto iniciado correctamente!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Servicios disponibles:" -ForegroundColor Cyan
Write-Host "  - Frontend (HTTPS): https://localhost" -ForegroundColor White
Write-Host "  - Frontend (HTTP):  http://localhost (redirige a HTTPS)" -ForegroundColor White
Write-Host "  - Backend API:      https://localhost:8081" -ForegroundColor White
Write-Host "  - Base de datos:    localhost:3307" -ForegroundColor White
Write-Host ""
Write-Host "Para ver los logs:" -ForegroundColor Yellow
Write-Host "  docker compose logs -f" -ForegroundColor White
Write-Host ""
Write-Host "Para detener los servicios:" -ForegroundColor Yellow
Write-Host "  docker compose down" -ForegroundColor White
Write-Host ""
Write-Host "Para reiniciar los servicios:" -ForegroundColor Yellow
Write-Host "  docker compose restart" -ForegroundColor White
Write-Host ""
