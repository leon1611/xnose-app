#!/bin/bash

# Script para generar APK usando GitHub Actions
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

print_info "🚀 Generando APK con GitHub Actions"
print_info "=================================="

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ] || [ ! -f ".github/workflows/build-android.yml" ]; then
    print_error "No se encontró package.json o workflow de GitHub Actions"
    print_error "Ejecuta este script desde el directorio frontend/"
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

# Verificar estado de Git
print_info "📋 Verificando estado de Git..."

if [ -z "$(git remote -v)" ]; then
    print_warning "⚠️  No hay repositorio remoto configurado"
    print_info "💡 Para usar GitHub Actions necesitas:"
    echo ""
    echo "1️⃣  Crear un repositorio en GitHub"
    echo "2️⃣  Configurar el remote:"
    echo "   git remote add origin https://github.com/TU_USUARIO/TU_REPO.git"
    echo "3️⃣  Subir el código:"
    echo "   git add ."
    echo "   git commit -m 'Configuración para APK'"
    echo "   git push -u origin main"
    echo ""
    print_info "🎯 Una vez configurado, el APK se generará automáticamente"
else
    print_success "✅ Repositorio remoto configurado"
    
    # Verificar si hay cambios pendientes
    if [ -n "$(git status --porcelain)" ]; then
        print_info "📝 Hay cambios pendientes, subiendo a GitHub..."
        
        git add .
        git commit -m "Configuración para generar APK - X-NOSE"
        git push
        
        print_success "✅ Código subido a GitHub"
        print_info "🔄 GitHub Actions se ejecutará automáticamente"
        print_info "📱 El APK estará disponible en:"
        echo "   https://github.com/TU_USUARIO/TU_REPO/actions"
    else
        print_info "✅ No hay cambios pendientes"
        print_info "🔄 GitHub Actions ya está configurado"
    fi
fi

print_info "📋 Configuración del workflow:"
echo "  - Archivo: .github/workflows/build-android.yml"
echo "  - Plataforma: Android"
echo "  - Variables configuradas:"
echo "    EXPO_PUBLIC_API_URL=https://xnose-gateway-service-431223568957.us-central1.run.app"
echo "    EXPO_PUBLIC_AI_SERVICE_URL=https://xnose-ai-service-jrms6vnyga-uc.a.run.app"

print_info "💡 Ventajas de GitHub Actions:"
echo "  ✅ Completamente gratuito"
echo "  ✅ Automático con cada commit"
echo "  ✅ APK descargable"
echo "  ✅ Historial de builds"
echo "  ✅ Configuración ya lista"

print_success "✅ Configuración completada"
print_info "🎯 Para generar APK:"
echo "  1. Configura el repositorio remoto (si no está configurado)"
echo "  2. Sube el código a GitHub"
echo "  3. El APK se generará automáticamente"
echo "  4. Descarga desde la pestaña Actions" 