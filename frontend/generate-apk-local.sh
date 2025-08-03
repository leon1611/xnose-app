#!/bin/bash

# Script para generar APK de X-NOSE usando métodos locales
# Configurado para usar las URLs de producción

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de logging
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Función principal
main() {
    print_info "🚀 Generando APK de X-NOSE (Método Local)"
    print_info "========================================="
    
    # Verificar que estamos en el directorio correcto
    if [ ! -f "package.json" ] || [ ! -f "app.config.prod.js" ]; then
        print_error "No se encontró package.json o app.config.prod.js"
        print_error "Ejecuta este script desde el directorio frontend/"
        exit 1
    fi
    
    print_info "📋 Configuración actual:"
    echo "  - Gateway URL: https://xnose-gateway-service-431223568957.us-central1.run.app"
    echo "  - AI Service URL: https://xnose-ai-service-jrms6vnyga-uc.a.run.app"
    echo "  - Base de datos: PostgreSQL (persistente)"
    
    # Verificar dependencias
    print_info "🔍 Verificando dependencias..."
    
    if ! command -v npx &> /dev/null; then
        print_error "npx no está disponible"
        exit 1
    fi
    
    # Instalar dependencias si es necesario
    print_info "📦 Instalando dependencias..."
    npm install
    
    # Verificar que los servicios estén funcionando
    print_info "🔗 Verificando servicios..."
    
    # Probar Gateway
    if curl -s -f "https://xnose-gateway-service-431223568957.us-central1.run.app/actuator/health" > /dev/null; then
        print_success "✅ Gateway Service funcionando"
    else
        print_error "❌ Gateway Service no responde"
        exit 1
    fi
    
    # Probar AI Service
    if curl -s -f "https://xnose-ai-service-jrms6vnyga-uc.a.run.app/health" > /dev/null; then
        print_success "✅ AI Service funcionando"
    else
        print_error "❌ AI Service no responde"
        exit 1
    fi
    
    print_info "🎯 Opciones para generar APK:"
    echo ""
    echo "  1️⃣  EAS Build (requiere cuenta Expo)"
    echo "  2️⃣  Expo Development Build"
    echo "  3️⃣  React Native CLI (requiere Android Studio)"
    echo "  4️⃣  Expo Go (para pruebas)"
    echo ""
    
    read -p "Selecciona una opción (1-4): " choice
    
    case $choice in
        1)
            print_info "🔧 Configurando EAS Build..."
            print_warning "Necesitarás una cuenta de Expo"
            npx eas-cli build:configure
            npx eas-cli build --platform android --profile production
            ;;
        2)
            print_info "🔧 Configurando Development Build..."
            npx expo install expo-dev-client
            npx expo run:android --variant release
            ;;
        3)
            print_info "🔧 Usando React Native CLI..."
            print_warning "Requiere Android Studio y SDK configurado"
            npx react-native run-android --variant=release
            ;;
        4)
            print_info "🔧 Usando Expo Go para pruebas..."
            print_info "Inicia el servidor de desarrollo:"
            echo "  npx expo start --config app.config.prod.js"
            echo ""
            print_info "Luego escanea el código QR con Expo Go"
            npx expo start --config app.config.prod.js
            ;;
        *)
            print_error "Opción inválida"
            exit 1
            ;;
    esac
    
    print_success "✅ Proceso completado!"
}

# Ejecutar función principal
main "$@" 