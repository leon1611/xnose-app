#!/bin/bash

echo "🚀 DESPLIEGUE COMPLETO DE X-NOSE EN RENDER"
echo "=========================================="
echo ""

# Función para mostrar menú
show_menu() {
    echo "📋 Selecciona una opción:"
    echo ""
    echo "1. 🔍 Obtener información necesaria para Render"
    echo "2. 🔧 Configurar Google Cloud Storage"
    echo "3. 🐳 Probar Docker localmente"
    echo "4. 🚀 Configurar Render automáticamente"
    echo "5. 📤 Subir código a GitHub"
    echo "6. ✅ Verificar despliegue"
    echo "7. 📚 Ver documentación"
    echo "8. ❌ Salir"
    echo ""
}

# Función para verificar prerequisitos
check_prerequisites() {
    echo "🔍 Verificando prerequisitos..."
    echo ""
    
    local missing=0
    
    # Verificar git
    if ! command -v git &> /dev/null; then
        echo "❌ Git no está instalado"
        missing=1
    else
        echo "✅ Git está instalado"
    fi
    
    # Verificar curl
    if ! command -v curl &> /dev/null; then
        echo "❌ curl no está instalado"
        missing=1
    else
        echo "✅ curl está instalado"
    fi
    
    # Verificar jq
    if ! command -v jq &> /dev/null; then
        echo "❌ jq no está instalado (instálalo con: brew install jq)"
        missing=1
    else
        echo "✅ jq está instalado"
    fi
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker no está instalado"
        missing=1
    else
        echo "✅ Docker está instalado"
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ Docker Compose no está instalado"
        missing=1
    else
        echo "✅ Docker Compose está instalado"
    fi
    
    if [ $missing -eq 1 ]; then
        echo ""
        echo "⚠️ Faltan algunos prerequisitos. Instálalos antes de continuar."
        return 1
    fi
    
    echo ""
    echo "✅ Todos los prerequisitos están instalados"
    return 0
}

# Función para verificar configuración de git
check_git_config() {
    echo "🔍 Verificando configuración de Git..."
    
    if ! git config --get user.name &> /dev/null; then
        echo "❌ Git no está configurado"
        echo "   Configura tu usuario:"
        echo "   git config --global user.name 'Tu Nombre'"
        echo "   git config --global user.email 'tu@email.com'"
        return 1
    fi
    
    if ! git config --get user.email &> /dev/null; then
        echo "❌ Email de Git no está configurado"
        echo "   Configura tu email:"
        echo "   git config --global user.email 'tu@email.com'"
        return 1
    fi
    
    echo "✅ Git está configurado correctamente"
    return 0
}

# Función para probar Docker localmente
test_docker() {
    echo "🐳 Probando Docker localmente..."
    echo ""
    
    echo "🔧 Construyendo imágenes..."
    if docker-compose build; then
        echo "✅ Imágenes construidas correctamente"
    else
        echo "❌ Error construyendo imágenes"
        return 1
    fi
    
    echo ""
    echo "🚀 Iniciando servicios..."
    if docker-compose up -d; then
        echo "✅ Servicios iniciados"
        echo ""
        echo "⏳ Esperando a que los servicios estén listos..."
        sleep 30
        
        echo ""
        echo "🔍 Verificando servicios..."
        if curl -f http://localhost:8080/actuator/health &> /dev/null; then
            echo "✅ Gateway Service está funcionando"
        else
            echo "❌ Gateway Service no responde"
        fi
        
        if curl -f http://localhost:8000/health &> /dev/null; then
            echo "✅ AI Service está funcionando"
        else
            echo "❌ AI Service no responde"
        fi
        
        if curl -f http://localhost:80/health &> /dev/null; then
            echo "✅ Frontend está funcionando"
        else
            echo "❌ Frontend no responde"
        fi
        
        echo ""
        echo "🌐 URLs de acceso local:"
        echo "   Frontend: http://localhost:80"
        echo "   Gateway: http://localhost:8080"
        echo "   AI Service: http://localhost:8000"
        echo ""
        echo "🛑 Para detener los servicios: docker-compose down"
        
    else
        echo "❌ Error iniciando servicios"
        return 1
    fi
}

# Función para subir código a GitHub
push_to_github() {
    echo "📤 Subiendo código a GitHub..."
    echo ""
    
    # Verificar si hay cambios sin commitear
    if ! git diff-index --quiet HEAD --; then
        echo "📝 Hay cambios sin commitear. Creando commit..."
        git add .
        git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M:%S') - Configuración Docker para Render"
    fi
    
    # Verificar si el repositorio remoto está configurado
    if ! git remote get-url origin &> /dev/null; then
        echo "❌ No hay repositorio remoto configurado."
        echo "📋 Configura el repositorio remoto:"
        echo "   git remote add origin https://github.com/tu-usuario/xnose.git"
        return 1
    fi
    
    # Hacer push
    echo "📤 Haciendo push al repositorio..."
    if git push origin main; then
        echo "✅ Código subido exitosamente"
        return 0
    else
        echo "❌ Error subiendo código"
        return 1
    fi
}

# Función principal
main() {
    echo "🎯 Bienvenido al despliegue de X-NOSE"
    echo ""
    
    # Verificar prerequisitos
    if ! check_prerequisites; then
        echo ""
        echo "❌ No se pueden cumplir los prerequisitos. Instala las herramientas necesarias."
        exit 1
    fi
    
    # Verificar configuración de git
    if ! check_git_config; then
        echo ""
        echo "❌ Git no está configurado correctamente."
        exit 1
    fi
    
    echo ""
    
    while true; do
        show_menu
        read -p "Selecciona una opción (1-8): " choice
        
        case $choice in
            1)
                echo ""
                ./scripts/get-render-info.sh
                ;;
            2)
                echo ""
                ./scripts/setup-google-cloud.sh
                ;;
            3)
                echo ""
                test_docker
                ;;
            4)
                echo ""
                ./scripts/setup-render.sh
                ;;
            5)
                echo ""
                push_to_github
                ;;
            6)
                echo ""
                ./scripts/verify-deployment.sh
                ;;
            7)
                echo ""
                echo "📚 DOCUMENTACIÓN DISPONIBLE:"
                echo "   - DEPLOYMENT.md - Guía completa de despliegue"
                echo "   - README.md - Documentación general del proyecto"
                echo "   - MANUAL_USUARIO_XNOSE.txt - Manual de usuario"
                echo "   - render.yaml - Configuración de servicios en Render"
                echo "   - docker-compose.yml - Configuración local con Docker"
                echo ""
                echo "📖 Para ver la documentación:"
                echo "   cat DEPLOYMENT.md"
                echo "   cat README.md"
                ;;
            8)
                echo ""
                echo "👋 ¡Hasta luego!"
                exit 0
                ;;
            *)
                echo ""
                echo "❌ Opción inválida. Selecciona un número del 1 al 8."
                ;;
        esac
        
        echo ""
        read -p "Presiona Enter para continuar..."
        echo ""
    done
}

# Ejecutar función principal
main 