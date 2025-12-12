# Script rápido para ejecutar el proyecto
# Usa este script si ya has ejecutado setup.ps1 anteriormente

Write-Host "Iniciando proyecto Docker..." -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker está corriendo
try {
    docker ps | Out-Null
} catch {
    Write-Host "✗ Docker no está corriendo. Por favor inicia Docker Desktop" -ForegroundColor Red
    exit 1
}

# Iniciar contenedores
docker compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Proyecto iniciado!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Servicios disponibles:" -ForegroundColor Cyan
    Write-Host "  - Frontend: https://localhost" -ForegroundColor White
    Write-Host "  - Backend:  https://localhost:8081" -ForegroundColor White
    Write-Host ""
    Write-Host "Para ver los logs: docker compose logs -f" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "✗ Error al iniciar. Ejecuta setup.ps1 primero." -ForegroundColor Red
}

