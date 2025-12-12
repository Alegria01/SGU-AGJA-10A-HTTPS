# Script para verificar la configuracion SSL del backend

Write-Host "Verificando configuracion SSL del backend..." -ForegroundColor Cyan
Write-Host ""

# Verificar que el contenedor este corriendo
$containerRunning = docker ps --filter "name=sgu-backend" --format "{{.Names}}"
if (-not $containerRunning) {
    Write-Host "[ERROR] El contenedor del backend no esta corriendo" -ForegroundColor Red
    Write-Host "Ejecuta: docker compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Contenedor del backend esta corriendo" -ForegroundColor Green
Write-Host ""

# Verificar que los certificados esten montados en el contenedor
Write-Host "Verificando certificados en el contenedor..." -ForegroundColor Yellow
$keystoreExists = docker exec sgu-backend test -f /etc/letsencrypt/live/localhost/keystore.p12
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Keystore encontrado en el contenedor" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Keystore NO encontrado en el contenedor" -ForegroundColor Red
    Write-Host "Ruta esperada: /etc/letsencrypt/live/localhost/keystore.p12" -ForegroundColor Yellow
}

$fullchainExists = docker exec sgu-backend test -f /etc/letsencrypt/live/localhost/fullchain.pem
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Certificado encontrado en el contenedor" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Certificado NO encontrado en el contenedor" -ForegroundColor Red
}

Write-Host ""
Write-Host "Verificando logs del backend..." -ForegroundColor Yellow
docker logs sgu-backend --tail 50

Write-Host ""
Write-Host "Para probar el backend directamente:" -ForegroundColor Cyan
Write-Host "  curl -k https://localhost:8081/api/users" -ForegroundColor White
Write-Host ""

