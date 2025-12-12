# Script para detener todos los contenedores

Write-Host "Deteniendo contenedores..." -ForegroundColor Yellow
docker compose down

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Contenedores detenidos" -ForegroundColor Green
} else {
    Write-Host "✗ Error al detener contenedores" -ForegroundColor Red
}

