# Script para reconstruir las imagenes y reiniciar los contenedores

Write-Host "Reconstruyendo imagenes Docker..." -ForegroundColor Cyan
Write-Host ""

# Detener contenedores
Write-Host "Deteniendo contenedores..." -ForegroundColor Yellow
docker compose down

# Reconstruir imagenes
Write-Host "Reconstruyendo imagenes (esto puede tardar varios minutos)..." -ForegroundColor Yellow
docker compose build --no-cache

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Error al reconstruir las imagenes" -ForegroundColor Red
    exit 1
}

# Iniciar contenedores
Write-Host ""
Write-Host "Iniciando contenedores..." -ForegroundColor Yellow
docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Error al iniciar los contenedores" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[OK] Proyecto reconstruido e iniciado!" -ForegroundColor Green
Write-Host ""
Write-Host "Esperando a que los servicios esten listos..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "Verificando estado de los contenedores..." -ForegroundColor Cyan
docker compose ps

Write-Host ""
Write-Host "Para ver los logs:" -ForegroundColor Yellow
Write-Host "  docker compose logs -f" -ForegroundColor White

