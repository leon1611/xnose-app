#!/bin/bash

# Script para generar APK usando Appetize.io
# Configurado específicamente para X-NOSE

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

print_info "🚀 Preparando proyecto para Appetize.io"
print_info "======================================"

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

# Crear archivo de configuración para Appetize
print_info "📝 Creando configuración para Appetize.io..."

cat > appetize-config.json << EOF
{
  "platform": "android",
  "buildType": "apk",
  "environment": {
    "EXPO_PUBLIC_API_URL": "https://xnose-gateway-service-431223568957.us-central1.run.app",
    "EXPO_PUBLIC_AI_SERVICE_URL": "https://xnose-ai-service-jrms6vnyga-uc.a.run.app",
    "EXPO_PUBLIC_GCS_BUCKET_URL": "https://storage.googleapis.com/petnow-dogs-images-app-biometrico-db"
  },
  "appConfig": {
    "name": "X-NOSE",
    "description": "Sistema de identificación biométrica para mascotas",
    "version": "1.0.0",
    "package": "com.mllituma.xnose"
  }
}
EOF

print_success "✅ Configuración creada: appetize-config.json"

# Crear archivo de instrucciones
cat > INSTRUCCIONES_APPETIZE.md << 'EOF'
# 🚀 Instrucciones para Appetize.io

## 📋 Pasos para generar APK:

### 1️⃣ Ir a Appetize.io
- Ve a: https://appetize.io
- Crea una cuenta gratuita
- Inicia sesión

### 2️⃣ Crear nuevo proyecto
- Haz clic en "New App"
- Nombre: "X-NOSE"
- Plataforma: Android
- Sube el archivo: `xnose-app-appetize.zip`

### 3️⃣ Configurar variables de entorno
En la sección "Environment Variables", agrega:
```
EXPO_PUBLIC_API_URL=https://xnose-gateway-service-431223568957.us-central1.run.app
EXPO_PUBLIC_AI_SERVICE_URL=https://xnose-ai-service-jrms6vnyga-uc.a.run.app
EXPO_PUBLIC_GCS_BUCKET_URL=https://storage.googleapis.com/petnow-dogs-images-app-biometrico-db
```

### 4️⃣ Configurar build
- Build Type: APK
- Platform: Android
- Framework: React Native/Expo

### 5️⃣ Generar APK
- Haz clic en "Build"
- Espera 5-10 minutos
- ¡APK listo para descargar!

## 📱 Funcionalidades del APK:
- ✅ Registro/Login de usuarios
- ✅ Registro de mascotas con fotos
- ✅ Escaneo de nariz con IA
- ✅ Alertas de mascotas perdidas
- ✅ Perfil de dueño
- ✅ Base de datos persistente

## 🔗 URLs de servicios:
- Gateway: https://xnose-gateway-service-431223568957.us-central1.run.app
- AI Service: https://xnose-ai-service-jrms6vnyga-uc.a.run.app
- Base de datos: PostgreSQL (Google Cloud)
EOF

print_success "✅ Instrucciones creadas: INSTRUCCIONES_APPETIZE.md"

# Crear ZIP optimizado para Appetize
print_info "🗜️  Creando archivo ZIP optimizado para Appetize.io..."

# Limpiar archivos anteriores
if [ -f "xnose-app-appetize.zip" ]; then
    rm xnose-app-appetize.zip
fi

# Crear ZIP con archivos necesarios
zip -r xnose-app-appetize.zip . \
    -x "node_modules/*" \
    -x ".expo/*" \
    -x "*.log" \
    -x ".DS_Store" \
    -x ".git/*" \
    -x "android/*" \
    -x "ios/*" \
    -x "build/*" \
    -x "dist/*" \
    -x "*.apk" \
    -x "*.aab"

if [ -f "xnose-app-appetize.zip" ]; then
    print_success "✅ Archivo ZIP creado: xnose-app-appetize.zip"
    print_info "📁 Tamaño: $(du -h xnose-app-appetize.zip | cut -f1)"
    print_info "📤 Listo para subir a Appetize.io"
else
    print_error "❌ Error al crear el archivo ZIP"
    exit 1
fi

print_info "🎯 Próximos pasos:"
echo ""
echo "1️⃣  Ve a: https://appetize.io"
echo "2️⃣  Crea una cuenta gratuita"
echo "3️⃣  Sube el archivo: xnose-app-appetize.zip"
echo "4️⃣  Configura las variables de entorno (ver INSTRUCCIONES_APPETIZE.md)"
echo "5️⃣  ¡Genera el APK!"
echo ""

print_success "✅ Todo listo para Appetize.io"
print_info "📖 Lee INSTRUCCIONES_APPETIZE.md para los pasos detallados" 