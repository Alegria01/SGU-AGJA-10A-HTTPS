# Script para verificar y crear certificados SSL
# Este script verifica si los certificados existen y los crea si es necesario

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verificacion y Creacion de Certificados SSL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$certBasePath = "C:\etc\letsencrypt"
$certLivePath = Join-Path $certBasePath "live\localhost"

# Verificar si OpenSSL esta disponible
Write-Host "[1/4] Verificando OpenSSL..." -ForegroundColor Yellow
$opensslPath = Get-Command openssl -ErrorAction SilentlyContinue
if (-not $opensslPath) {
    Write-Host "  [ADVERTENCIA] OpenSSL no encontrado en el PATH" -ForegroundColor Yellow
    Write-Host "  Intentando usar OpenSSL de Git (si esta instalado)..." -ForegroundColor Yellow
    
    $gitOpenSSL = "C:\Program Files\Git\usr\bin\openssl.exe"
    if (Test-Path $gitOpenSSL) {
        $env:PATH += ";C:\Program Files\Git\usr\bin"
        Write-Host "  [OK] OpenSSL encontrado en Git" -ForegroundColor Green
    } else {
        Write-Host "  [ERROR] OpenSSL no encontrado" -ForegroundColor Red
        Write-Host ""
        Write-Host "Por favor instala OpenSSL:" -ForegroundColor Yellow
        Write-Host "  1. Descarga desde: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor White
        Write-Host "  2. O instala Git for Windows que incluye OpenSSL" -ForegroundColor White
        Write-Host ""
        exit 1
    }
}

# Verificar si los certificados ya existen
Write-Host "[2/4] Verificando certificados existentes..." -ForegroundColor Yellow
$fullchain = Join-Path $certLivePath "fullchain.pem"
$privkey = Join-Path $certLivePath "privkey.pem"
$keystore = Join-Path $certLivePath "keystore.p12"

$certificatesExist = $false
if ((Test-Path $fullchain) -and (Test-Path $privkey)) {
    Write-Host "  [OK] Certificados encontrados en: $certLivePath" -ForegroundColor Green
    
    # Verificar validez de los certificados
    $certInfo = openssl x509 -in $fullchain -noout -dates -ErrorAction SilentlyContinue
    if ($certInfo) {
        Write-Host "  [OK] Certificados validos" -ForegroundColor Green
        $certificatesExist = $true
    } else {
        Write-Host "  [ADVERTENCIA] Certificados invalidos o corruptos" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [INFO] Certificados no encontrados" -ForegroundColor Yellow
}

# Crear directorios si no existen
if (-not $certificatesExist) {
    Write-Host "[3/4] Creando estructura de directorios..." -ForegroundColor Yellow
    if (-not (Test-Path $certBasePath)) {
        New-Item -ItemType Directory -Path $certBasePath -Force | Out-Null
        Write-Host "  [OK] Directorio base creado: $certBasePath" -ForegroundColor Green
    }
    
    if (-not (Test-Path $certLivePath)) {
        New-Item -ItemType Directory -Path $certLivePath -Force | Out-Null
        Write-Host "  [OK] Directorio de certificados creado: $certLivePath" -ForegroundColor Green
    }
    
    # Crear archivo de configuracion para OpenSSL
    Write-Host "[4/4] Generando certificados SSL autofirmados..." -ForegroundColor Yellow
    
    $configFile = Join-Path $env:TEMP "openssl.conf"
    $configContent = @"
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=MX
ST=Estado
L=Ciudad
O=Desarrollo
OU=IT
CN=localhost

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = *.localhost
IP.1 = 127.0.0.1
IP.2 = ::1
"@
    
    Set-Content -Path $configFile -Value $configContent -Encoding UTF8
    
    # Generar clave privada
    Write-Host "  Generando clave privada..." -ForegroundColor Cyan
    $privkeyTemp = Join-Path $env:TEMP "privkey_temp.pem"
    openssl genrsa -out $privkeyTemp 2048 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERROR] Error al generar clave privada" -ForegroundColor Red
        exit 1
    }
    
    # Generar certificado
    Write-Host "  Generando certificado..." -ForegroundColor Cyan
    $certTemp = Join-Path $env:TEMP "cert_temp.pem"
    openssl req -new -x509 -key $privkeyTemp -out $certTemp -days 365 -config $configFile -extensions v3_req 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERROR] Error al generar certificado" -ForegroundColor Red
        exit 1
    }
    
    # Copiar certificados a la ubicacion final
    Copy-Item $privkeyTemp $privkey -Force
    Copy-Item $certTemp $fullchain -Force
    
    # Crear fullchain.pem (en este caso es el mismo que el certificado)
    # En produccion, fullchain incluiria tambien la cadena de certificados intermedios
    
    Write-Host "  [OK] Certificados creados exitosamente" -ForegroundColor Green
    
    # Crear keystore.p12 para Spring Boot
    Write-Host "  Generando keystore para Spring Boot..." -ForegroundColor Cyan
    $keystorePassword = "changeit"
    
    # Convertir certificado y clave a formato PKCS12
    openssl pkcs12 -export -in $fullchain -inkey $privkey -out $keystore -name "localhost" -password "pass:$keystorePassword" -noiter -nomaciter 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Keystore creado exitosamente" -ForegroundColor Green
        Write-Host "  [INFO] Contrasena del keystore: $keystorePassword" -ForegroundColor Cyan
    } else {
        Write-Host "  [ADVERTENCIA] No se pudo crear el keystore, pero los certificados PEM estan listos" -ForegroundColor Yellow
    }
    
    # Limpiar archivos temporales
    Remove-Item $configFile -ErrorAction SilentlyContinue
    Remove-Item $privkeyTemp -ErrorAction SilentlyContinue
    Remove-Item $certTemp -ErrorAction SilentlyContinue
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  [OK] Certificados SSL creados!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    # Verificar si existe el keystore
    if (-not (Test-Path $keystore)) {
        Write-Host "[4/4] Generando keystore para Spring Boot..." -ForegroundColor Yellow
        $keystorePassword = "changeit"
        
        openssl pkcs12 -export -in $fullchain -inkey $privkey -out $keystore -name "localhost" -password "pass:$keystorePassword" -noiter -nomaciter 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Keystore creado exitosamente" -ForegroundColor Green
            Write-Host "  [INFO] Contrasena del keystore: $keystorePassword" -ForegroundColor Cyan
        } else {
            Write-Host "  [ADVERTENCIA] No se pudo crear el keystore" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [OK] Keystore ya existe" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  [OK] Certificados SSL verificados!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}

Write-Host ""
Write-Host "Ubicacion de los certificados:" -ForegroundColor Cyan
Write-Host "  - Certificado: $fullchain" -ForegroundColor White
Write-Host "  - Clave privada: $privkey" -ForegroundColor White
Write-Host "  - Keystore: $keystore" -ForegroundColor White
Write-Host ""
Write-Host "NOTA: Estos son certificados autofirmados para desarrollo." -ForegroundColor Yellow
Write-Host "      Tu navegador mostrara una advertencia de seguridad." -ForegroundColor Yellow
Write-Host "      Para produccion, usa certificados de Let's Encrypt o una CA valida." -ForegroundColor Yellow
Write-Host ""

