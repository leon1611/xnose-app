#!/bin/bash

# Script para configurar GitHub y generar APK automáticamente
# Completamente gratuito y automático

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

print_info "🚀 Configurando GitHub para generar APK automáticamente"
print_info "======================================================"

# Verificar que estamos en el directorio correcto
if [ ! -f "frontend/package.json" ] || [ ! -f "frontend/.github/workflows/build-android.yml" ]; then
    print_error "No se encontró package.json o workflow de GitHub Actions"
    print_error "Ejecuta este script desde el directorio raíz del proyecto"
    exit 1
fi

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

print_info "📋 Estado actual del repositorio:"
git status --porcelain | head -5

print_info "🎯 Pasos para configurar GitHub:"
echo ""
echo "1️⃣  CREAR REPOSITORIO EN GITHUB:"
echo "   - Ve a: https://github.com/new"
echo "   - Nombre: xnose-app (o el que prefieras)"
echo "   - Descripción: X-NOSE - Sistema de identificación biométrica"
echo "   - NO inicialices con README"
echo "   - Crea el repositorio"
echo ""
echo "2️⃣  CONFIGURAR REMOTE (reemplaza TU_USUARIO y TU_REPO):"
echo "   git remote add origin https://github.com/TU_USUARIO/TU_REPO.git"
echo ""
echo "3️⃣  SUBIR CÓDIGO:"
echo "   git push -u origin main"
echo ""
echo "4️⃣  VERIFICAR ACTIONS:"
echo "   Ve a: https://github.com/TU_USUARIO/TU_REPO/actions"
echo ""

print_info "💡 Una vez configurado:"
echo "  ✅ El APK se generará automáticamente"
echo "  ✅ Estará disponible para descargar"
echo "  ✅ Se actualizará con cada commit"
echo "  ✅ Completamente gratuito"

print_info "📋 Configuración del workflow:"
echo "  - Archivo: frontend/.github/workflows/build-android.yml"
echo "  - Plataforma: Android"
echo "  - Variables configuradas:"
echo "    EXPO_PUBLIC_API_URL=https://xnose-gateway-service-431223568957.us-central1.run.app"
echo "    EXPO_PUBLIC_AI_SERVICE_URL=https://xnose-ai-service-jrms6vnyga-uc.a.run.app"

print_success "✅ Todo listo para configurar GitHub"
print_info "🎯 Sigue los pasos arriba y el APK se generará automáticamente" 