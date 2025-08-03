#!/bin/bash

# 🚀 X-NOSE - Despliegue Completo en Google Cloud
# Este script ejecuta todo el proceso de despliegue de forma automatizada

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para mostrar banner
show_banner() {
    echo ""
    echo "🚀 X-NOSE - Despliegue Completo en Google Cloud"
    echo "================================================"
    echo "🐕 Sistema de identificación de perros por huella nasal"
    echo "☁️  Despliegue automatizado en Google Cloud Platform"
    echo "📱 Generación automática de APK"
    echo ""
}

# Función para verificar prerequisitos
check_prerequisites() {
    print_message "Verificando prerequisitos..."
    
    # Verificar Google Cloud CLI
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud CLI no está instalado"
        echo "Instala desde: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        echo "Instala desde: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Verificar que Docker esté ejecutándose
    if ! docker info &> /dev/null; then
        print_error "Docker no está ejecutándose"
        echo "Inicia Docker Desktop o el servicio de Docker"
        exit 1
    fi
    
    # Verificar Node.js (para el frontend)
    if ! command -v node &> /dev/null; then
        print_warning "Node.js no está instalado (necesario para generar APK)"
        echo "Instala desde: https://nodejs.org/"
    fi
    
    print_success "Prerequisitos verificados"
}

# Función para confirmar despliegue
confirm_deployment() {
    echo ""
    print_warning "⚠️  IMPORTANTE: Este proceso desplegará X-NOSE en Google Cloud"
    echo ""
    echo "📋 Lo que se hará:"
    echo "   1. Configurar Google Cloud Platform"
    echo "   2. Construir y subir imágenes Docker"
    echo "   3. Desplegar 6 servicios en Cloud Run"
    echo "   4. Configurar frontend para producción"
    echo "   5. Generar APK de la aplicación"
    echo ""
    echo "💰 Costos estimados: $60-95/mes"
    echo "⏱️  Tiempo estimado: 15-30 minutos"
    echo ""
    
    read -p "¿Continuar con el despliegue? (y/n): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "Despliegue cancelado"
        exit 0
    fi
    
    print_success "Despliegue confirmado"
}

# Función para ejecutar paso con manejo de errores
execute_step() {
    local step_name=$1
    local step_script=$2
    
    echo ""
    print_message "🔄 Ejecutando: $step_name"
    echo "=================================="
    
    if [ -f "$step_script" ]; then
        if bash "$step_script"; then
            print_success "✅ $step_name completado"
        else
            print_error "❌ Error en $step_name"
            echo ""
            echo "🔧 Solución de problemas:"
            echo "   1. Verifica los logs arriba"
            echo "   2. Asegúrate de tener permisos en Google Cloud"
            echo "   3. Verifica que Docker esté ejecutándose"
            echo "   4. Ejecuta manualmente: $step_script"
            echo ""
            exit 1
        fi
    else
        print_error "Script no encontrado: $step_script"
        exit 1
    fi
}

# Función para mostrar progreso
show_progress() {
    local current_step=$1
    local total_steps=$2
    
    local percentage=$((current_step * 100 / total_steps))
    local filled=$((percentage / 2))
    local empty=$((50 - filled))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%% (%d/%d)" $percentage $current_step $total_steps
}

# Función principal de despliegue
main_deployment() {
    local total_steps=5
    local current_step=0
    
    # Paso 1: Configurar Google Cloud
    current_step=1
    show_progress $current_step $total_steps
    execute_step "Configuración de Google Cloud" "./scripts/setup-gcp.sh"
    
    # Paso 2: Construir y subir imágenes
    current_step=2
    show_progress $current_step $total_steps
    execute_step "Construcción y subida de imágenes" "./scripts/build-and-push.sh"
    
    # Paso 3: Desplegar servicios
    current_step=3
    show_progress $current_step $total_steps
    execute_step "Despliegue de servicios" "./scripts/deploy-services.sh"
    
    # Paso 4: Actualizar configuración del frontend
    current_step=4
    show_progress $current_step $total_steps
    execute_step "Configuración del frontend" "./scripts/update-frontend-config.sh"
    
    # Paso 5: Generar APK
    current_step=5
    show_progress $current_step $total_steps
    print_message "🔄 Generando APK..."
    echo "=================================="
    
    cd ../../frontend
    if [ -f "generate-apk.sh" ]; then
        if bash "generate-apk.sh"; then
            print_success "✅ APK generado exitosamente"
        else
            print_warning "⚠️ Error generando APK (puedes generarlo manualmente después)"
        fi
    else
        print_warning "⚠️ Script de generación de APK no encontrado"
    fi
    
    cd ../gcp-deploy
    
    echo ""
    print_success "🎉 ¡Despliegue completado exitosamente!"
}

# Función para mostrar resumen final
show_final_summary() {
    echo ""
    echo "🎯 RESUMEN DEL DESPLIEGUE"
    echo "=========================="
    echo ""
    
    # Cargar configuración para mostrar URLs
    if [ -f "configs/gcp-config.env" ]; then
        source configs/gcp-config.env
        
        echo "🌐 URLs de Servicios:"
        echo "   Gateway: $GATEWAY_URL"
        echo "   Auth: $AUTH_URL"
        echo "   Owner: $OWNER_URL"
        echo "   Pet: $PET_URL"
        echo "   Alert: $ALERT_URL"
        echo "   AI: $AI_URL"
        echo ""
    fi
    
    echo "📱 APK:"
    echo "   El archivo APK se encuentra en la carpeta de descargas de Expo"
    echo "   Para regenerar: cd ../frontend && ./generate-apk.sh"
    echo ""
    
    echo "🔧 Monitoreo:"
    echo "   Verificar servicios: ./scripts/monitor-services.sh"
    echo "   Monitoreo continuo: ./scripts/monitor-services.sh continuous"
    echo "   Ver logs: ./scripts/monitor-services.sh logs <service-name>"
    echo ""
    
    echo "💰 Costos:"
    echo "   Estimado mensual: $60-95"
    echo "   Monitorear en: https://console.cloud.google.com/billing"
    echo ""
    
    echo "🔒 Seguridad:"
    echo "   ✅ Código fuente protegido (solo imágenes Docker)"
    echo "   ✅ SSL/TLS automático"
    echo "   ✅ Variables de entorno seguras"
    echo ""
    
    print_success "¡X-NOSE está listo para usar en producción!"
}

# Función principal
main() {
    show_banner
    check_prerequisites
    confirm_deployment
    main_deployment
    show_final_summary
}

# Manejo de interrupciones
trap 'echo ""; print_error "Despliegue interrumpido"; exit 1' INT TERM

# Ejecutar función principal
main "$@" 