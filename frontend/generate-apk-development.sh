#!/bin/bash

# Script para generar APK usando Expo Development Build
# Configurado para usar las URLs de producción

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_info "🚀 Generando APK de X-NOSE (Development Build)"
print_info "=============================================="

# Verificar servicios
print_info "🔗 Verificando servicios..."

if curl -s -f "https://xnose-gateway-service-431223568957.us-central1.run.app/actuator/health" > /dev/null; then
    print_success "✅ Gateway Service funcionando"
else
    print_error "❌ Gateway Service no responde"
    exit 1
fi

if curl -s -f "https://xnose-ai-service-jrms6vnyga-uc.a.run.app/health" > /dev/null; then
    print_success "✅ AI Service funcionando"
else
    print_error "❌ AI Service no responde"
    exit 1
fi

# Configurar variables de entorno
export EXPO_PUBLIC_API_URL="https://xnose-gateway-service-431223568957.us-central1.run.app"
export EXPO_PUBLIC_AI_SERVICE_URL="https://xnose-ai-service-jrms6vnyga-uc.a.run.app"

print_info "📋 Variables de entorno configuradas:"
echo "  - API URL: $EXPO_PUBLIC_API_URL"
echo "  - AI Service URL: $EXPO_PUBLIC_AI_SERVICE_URL"

# Instalar dependencias
print_info "📦 Instalando dependencias..."
npm install

# Verificar que expo-dev-client esté instalado
print_info "🔧 Verificando expo-dev-client..."
if ! npm list expo-dev-client > /dev/null 2>&1; then
    print_info "Instalando expo-dev-client..."
    npx expo install expo-dev-client
fi

print_info "🎯 Intentando generar APK con Expo Development Build..."

# Intentar generar el APK
if npx expo run:android --variant release; then
    print_success "✅ APK generado exitosamente"
    print_info "📱 El APK estará en: android/app/build/outputs/apk/release/"
else
    print_warning "⚠️  Expo Development Build falló"
    print_info "💡 Esto puede requerir Android Studio configurado"
    
    print_info "🎯 Alternativa: Usar Expo Go para pruebas"
    print_info "📱 Para probar la app:"
    echo "  1. Instala Expo Go en tu dispositivo Android"
    echo "  2. Ejecuta: npx expo start"
    echo "  3. Escanea el código QR"
    echo ""
    
    read -p "¿Quieres iniciar el servidor para Expo Go? (y/n): " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        print_info "🚀 Iniciando servidor para Expo Go..."
        npx expo start --clear
    else
        print_info "💡 Para generar APK, necesitarás:"
        echo "  - Android Studio instalado"
        echo "  - Android SDK configurado"
        echo "  - O usar EAS Build (requiere cuenta Expo)"
    fi
fi

print_success "✅ Proceso completado" 