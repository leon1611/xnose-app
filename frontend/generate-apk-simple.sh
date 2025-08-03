#!/bin/bash

# Script simple para generar APK de X-NOSE
# Usando Expo Development Build

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

print_info "🚀 Generando APK de X-NOSE (Método Simple)"
print_info "=========================================="

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

# Intentar generar APK usando diferentes métodos
print_info "🔧 Intentando generar APK..."

# Método 1: EAS Build (sin login)
print_info "1️⃣  Intentando EAS Build..."
if npx eas-cli build --platform android --profile preview --non-interactive 2>/dev/null; then
    print_success "✅ APK generado con EAS Build"
    exit 0
else
    print_warning "⚠️  EAS Build requiere login"
fi

# Método 2: Expo Development Build
print_info "2️⃣  Intentando Expo Development Build..."
if npx expo run:android --variant release 2>/dev/null; then
    print_success "✅ APK generado con Expo Development Build"
    exit 0
else
    print_warning "⚠️  Expo Development Build requiere configuración adicional"
fi

# Método 3: React Native CLI
print_info "3️⃣  Intentando React Native CLI..."
if npx react-native run-android --variant=release 2>/dev/null; then
    print_success "✅ APK generado con React Native CLI"
    exit 0
else
    print_warning "⚠️  React Native CLI requiere Android Studio"
fi

# Método 4: Expo Go (para pruebas)
print_info "4️⃣  Iniciando servidor para Expo Go..."
print_info "📱 Para probar la app:"
echo "  1. Instala Expo Go en tu dispositivo Android"
echo "  2. Escanea el código QR que aparecerá"
echo "  3. La app se cargará con la configuración de producción"
echo ""

npx expo start --clear

print_success "✅ Servidor iniciado para pruebas con Expo Go"
print_info "💡 Para generar un APK real, necesitarás:"
echo "  - Una cuenta de Expo (gratuita)"
echo "  - O Android Studio configurado"
echo "  - O usar un servicio de build como EAS" 