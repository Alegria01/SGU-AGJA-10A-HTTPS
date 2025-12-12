pipeline {
    agent any

    environment {
        CERT_PATH = 'C:\\etc\\letsencrypt'
    }

    stages {

        // 📥 OBTENER CÓDIGO DEL SCM
        stage('Obteniendo código del repositorio...') {
            steps {
                checkout scm
            }
        }

        // 🔐 VERIFICAR Y CREAR CERTIFICADOS SSL
        stage('Verificando certificados SSL...') {
            steps {
                bat '''
                    echo === Verificando certificados SSL ===
                    
                    set CERT_LIVE_PATH=%CERT_PATH%\\live\\localhost
                    
                    if not exist "%CERT_PATH%" (
                        echo Creando directorio base de certificados...
                        mkdir "%CERT_PATH%" 2>nul
                    )
                    
                    if not exist "%CERT_LIVE_PATH%" (
                        echo Creando directorio de certificados...
                        mkdir "%CERT_LIVE_PATH%" 2>nul
                    )
                    
                    if not exist "%CERT_LIVE_PATH%\\fullchain.pem" (
                        echo Certificados no encontrados. Ejecutando script de creacion...
                        if exist "setup-certificates.ps1" (
                            powershell -ExecutionPolicy Bypass -File setup-certificates.ps1
                            
                            if %ERRORLEVEL% NEQ 0 (
                                echo ERROR: No se pudieron crear los certificados SSL
                                exit /b 1
                            )
                        ) else (
                            echo ADVERTENCIA: Script setup-certificates.ps1 no encontrado
                            echo Los certificados deben crearse manualmente antes del despliegue
                        )
                    ) else (
                        echo Certificados SSL encontrados en %CERT_LIVE_PATH%
                    )
                '''
            }
        }

        // 🗂️ CREAR VOLÚMENES Y REDES DOCKER
        stage('Creando volúmenes y redes Docker...') {
            steps {
                bat '''
                    echo === Creando volúmenes Docker ===
                    
                    docker volume create sgu-volume 2>nul
                    IF %ERRORLEVEL% NEQ 0 (
                        echo Volumen sgu-volume ya existe, continuando...
                    ) ELSE (
                        echo Volumen sgu-volume creado correctamente
                    )
                    
                    docker volume create certbot-conf 2>nul
                    IF %ERRORLEVEL% NEQ 0 (
                        echo Volumen certbot-conf ya existe, continuando...
                    ) ELSE (
                        echo Volumen certbot-conf creado correctamente
                    )
                    
                    echo === Creando red Docker ===
                    docker network create sgu-net 2>nul
                    IF %ERRORLEVEL% NEQ 0 (
                        echo Red sgu-net ya existe, continuando...
                    ) ELSE (
                        echo Red sgu-net creada correctamente
                    )
                    
                    echo Volúmenes y red verificados/creados
                    echo Continuando con el despliegue...
                '''
            }
        }

        // 🛑 DETENER SERVICIOS EXISTENTES
        stage('Deteniendo servicios previos...') {
            steps {
                bat '''
                    echo === Deteniendo servicios previos ===
                    docker compose down
                    IF %ERRORLEVEL% NEQ 0 (
                        echo No hay servicios corriendo o ya fueron detenidos, continuando...
                    ) ELSE (
                        echo Servicios detenidos correctamente
                    )
                    
                    echo Continuando con el despliegue...
                '''
            }
        }

        // 🗑 ELIMINAR IMÁGENES ANTERIORES (OPCIONAL)
        stage('Limpiando imágenes anteriores...') {
            steps {
                bat '''
                    echo === Limpiando imágenes anteriores ===
                    
                    docker rmi client:1.0-sgu 2>nul
                    IF %ERRORLEVEL% NEQ 0 (
                        echo Imagen client:1.0-sgu no existe o ya fue eliminada, continuando...
                    ) ELSE (
                        echo Imagen client:1.0-sgu eliminada correctamente
                    )
                    
                    docker rmi server:1.0-sgu 2>nul
                    IF %ERRORLEVEL% NEQ 0 (
                        echo Imagen server:1.0-sgu no existe o ya fue eliminada, continuando...
                    ) ELSE (
                        echo Imagen server:1.0-sgu eliminada correctamente
                    )
                    
                    echo Limpieza completada
                '''
            }
        }

        // 🚀 CONSTRUIR Y DESPLEGAR SERVICIOS
        stage('Construyendo y desplegando servicios...') {
            steps {
                bat '''
                    echo === Construyendo imágenes Docker ===
                    echo Esto puede tardar varios minutos en la primera ejecucion...
                    
                    docker compose build --no-cache
                    
                    IF %ERRORLEVEL% NEQ 0 (
                        echo ERROR: Falló la construcción de las imágenes
                        echo Revisando logs...
                        docker compose logs
                        exit /b 1
                    )
                    
                    echo === Iniciando servicios ===
                    echo Configurando variable CERT_PATH=%CERT_PATH%
                    set CERT_PATH=%CERT_PATH%
                    docker compose up -d
                    
                    IF %ERRORLEVEL% NEQ 0 (
                        echo ERROR: Falló el despliegue de los servicios
                        echo Revisando logs...
                        docker compose logs
                        exit /b 1
                    )
                    
                    echo === Esperando a que los servicios estén listos ===
                    timeout /t 20 /nobreak
                    
                    echo === Verificando que los contenedores estén corriendo ===
                    docker compose ps
                '''
            }
        }

        // ✅ VERIFICAR ESTADO DE LOS SERVICIOS
        stage('Verificando estado de los servicios...') {
            steps {
                bat '''
                    echo === Estado de los contenedores ===
                    docker compose ps
                    
                    echo === Verificando salud de los servicios ===
                    docker compose ps --format "table {{.Name}}\t{{.Status}}"
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline ejecutado con éxito'
            bat '''
                echo.
                echo ========================================
                echo   DESPLIEGUE COMPLETADO
                echo ========================================
                echo.
                echo Servicios disponibles:
                echo   - Frontend (HTTPS): https://localhost
                echo   - Backend API:      https://localhost:8081
                echo   - Base de datos:    localhost:3307
                echo.
                echo Para ver los logs:
                echo   docker compose logs -f
                echo.
            '''
        }
        failure {
            echo '❌ Hubo un error al ejecutar el pipeline'
            bat '''
                echo.
                echo ========================================
                echo   ERROR EN EL DESPLIEGUE
                echo ========================================
                echo.
                echo Revisando logs de los servicios...
                docker compose logs --tail=50
                echo.
            '''
        }
        always {
            echo 'Pipeline finalizado'
        }
    }
}
