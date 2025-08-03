#!/bin/bash

# Script para generar APK de X-NOSE
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

# Verificar que estamos en el directorio correcto
check_directory() {
    if [ ! -f "package.json" ] || [ ! -f "app.config.prod.js" ]; then
        print_error "No se encontró package.json o app.config.prod.js"
        print_error "Ejecuta este script desde el directorio frontend/"
        exit 1
    fi
}

# Verificar dependencias
check_dependencies() {
    print_info "Verificando dependencias..."
    
    if ! command -v expo &> /dev/null; then
        print_error "Expo CLI no está instalado"
        print_info "Instala con: npm install -g @expo/cli"
        exit 1
    fi
    
    if ! command -v eas &> /dev/null; then
        print_warning "EAS CLI no está instalado"
        print_info "Instala con: npm install -g @expo/eas-cli"
    fi
    
    print_success "Dependencias verificadas"
}

# Instalar dependencias si es necesario
install_dependencies() {
    print_info "Instalando dependencias..."
    
    if [ ! -d "node_modules" ]; then
        npm install
        print_success "Dependencias instaladas"
    else
        print_info "Dependencias ya instaladas"
    fi
}

# Generar APK
generate_apk() {
    print_info "Generando APK..."
    
    # Usar la configuración de producción
    expo build:android --type apk --config app.config.prod.js
    
    if [ $? -eq 0 ]; then
        print_success "APK generado exitosamente"
        print_info "El APK estará disponible en la consola de Expo"
    else
        print_error "Error al generar APK"
        exit 1
    fi
}

# Función principal
main() {
    print_info "🚀 Generando APK de X-NOSE"
    print_info "=========================="
    
    check_directory
    check_dependencies
    install_dependencies
    generate_apk
    
    print_success "¡Proceso completado!"
    print_info "Revisa la consola de Expo para descargar el APK"
}

# Ejecutar función principal
main "$@" 