#!/bin/bash

# Script para generar APK firmado de X-NOSE
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

print_info "🚀 Generando APK firmado de X-NOSE"
print_info "=================================="

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ] || [ ! -d "android" ]; then
    print_error "No se encontró package.json o directorio android"
    print_error "Ejecuta este script desde el directorio frontend/"
    exit 1
fi

# Verificar servicios
print_info "🔗 Verificando servicios..."

if curl -s -f "https://xnose-gateway-service-431223568957.us-central1.run.app/api/auth/health" > /dev/null; then
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

# Verificar Java
print_info "☕ Verificando Java..."
if ! command -v java &> /dev/null; then
    print_error "Java no está instalado"
    exit 1
fi

java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
print_success "✅ Java $java_version instalado"

# Generar keystore si no existe
print_info "🔑 Generando keystore..."
cd android/app
if [ ! -f "xnose-key.keystore" ]; then
    keytool -genkey -v -keystore xnose-key.keystore -alias xnose-key -keyalg RSA -keysize 2048 -validity 10000 -storepass xnose123 -keypass xnose123 -dname "CN=XNOSE, OU=Development, O=XNOSE, L=City, S=State, C=US"
    print_success "✅ Keystore generado"
else
    print_info "✅ Keystore ya existe"
fi

# Construir APK firmado
print_info "🔨 Construyendo APK firmado..."
cd ..
./gradlew assembleRelease

if [ $? -eq 0 ]; then
    print_success "✅ APK firmado generado exitosamente"
    
    # Mostrar ubicación del APK
    apk_path="app/build/outputs/apk/release/app-release.apk"
    if [ -f "$apk_path" ]; then
        print_success "📱 APK disponible en: $apk_path"
        print_info "📏 Tamaño: $(du -h $apk_path | cut -f1)"
        
        # Verificar que es un APK válido
        if file "$apk_path" | grep -q "Android application package"; then
            print_success "✅ APK válido y firmado"
            print_info "📱 Instala este APK en tu dispositivo Android"
        else
            print_warning "⚠️  El archivo no parece ser un APK válido"
        fi
    else
        print_error "❌ APK no encontrado en la ubicación esperada"
    fi
else
    print_error "❌ Error al generar APK"
    exit 1
fi

print_success "✅ Proceso completado"
print_info "🎯 APK firmado listo para instalar" 