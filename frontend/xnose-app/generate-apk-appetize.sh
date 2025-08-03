#!/bin/bash

# Script para generar APK usando Appetize.io
# Alternativa a EAS Build que no requiere Android Studio

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

print_info "🚀 Generando APK usando Appetize.io"
print_info "==================================="

print_info "📋 Appetize.io es un servicio online que puede generar APKs"
print_info "💡 Ventajas:"
echo "  - No requiere Android Studio"
echo "  - Proceso automatizado"
echo "  - APK listo para distribución"
echo "  - Pruebas en emulador online"

print_info "🔗 Pasos para usar Appetize.io:"
echo ""
echo "1️⃣  Ve a https://appetize.io"
echo "2️⃣  Crea una cuenta gratuita"
echo "3️⃣  Sube tu proyecto (ZIP del frontend)"
echo "4️⃣  Configura las variables de entorno:"
echo "    - EXPO_PUBLIC_API_URL=https://xnose-gateway-service-431223568957.us-central1.run.app"
echo "    - EXPO_PUBLIC_AI_SERVICE_URL=https://xnose-ai-service-jrms6vnyga-uc.a.run.app"
echo "5️⃣  Genera el APK"
echo ""

print_info "📦 Preparando proyecto para Appetize.io..."

# Crear ZIP del proyecto
if [ -f "xnose-app.zip" ]; then
    rm xnose-app.zip
fi

print_info "🗜️  Creando archivo ZIP del proyecto..."
zip -r xnose-app.zip . -x "node_modules/*" ".expo/*" "*.log" ".DS_Store"

if [ -f "xnose-app.zip" ]; then
    print_success "✅ Archivo ZIP creado: xnose-app.zip"
    print_info "📁 Tamaño: $(du -h xnose-app.zip | cut -f1)"
    print_info "📤 Sube este archivo a Appetize.io"
else
    print_error "❌ Error al crear el archivo ZIP"
fi

print_info "💡 Otras alternativas:"
echo ""
echo "🔧 BuildFire: https://buildfire.com"
echo "🔧 PhoneGap Build: https://build.phonegap.com"
echo "🔧 Ionic Appflow: https://ionicframework.com/appflow"
echo "🔧 Codemagic: https://codemagic.io"
echo ""

print_success "✅ Proceso completado" 