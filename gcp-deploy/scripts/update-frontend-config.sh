#!/bin/bash

# 🚀 X-NOSE - Actualizar Configuración del Frontend
# Este script actualiza la configuración del frontend con las URLs de producción

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

# Cargar configuración
load_config() {
    if [ ! -f "gcp-deploy/configs/gcp-config.env" ]; then
        print_error "Archivo de configuración no encontrado. Ejecuta primero: ./scripts/setup-gcp.sh"
        exit 1
    fi
    
    source gcp-deploy/configs/gcp-config.env
    print_success "Configuración cargada"
}

# Verificar que las URLs estén configuradas
verify_urls() {
    if [ -z "$GATEWAY_URL" ] || [ -z "$AI_URL" ]; then
        print_error "URLs de servicios no configuradas"
        print_error "Ejecuta primero: ./scripts/deploy-services.sh"
        exit 1
    fi
    
    print_success "URLs verificadas"
    echo "Gateway: $GATEWAY_URL"
    echo "AI Service: $AI_URL"
}

# Crear configuración de producción para el frontend
create_production_config() {
    print_message "Creando configuración de producción para el frontend..."
    
    # Crear archivo de configuración de producción
    cat > ../frontend/app.config.prod.js << EOF
export default {
  expo: {
    name: "X-NOSE",
    slug: "xnose-app",
    version: "1.0.0",
    orientation: "portrait",
    icon: "./assets/icon.png",
    userInterfaceStyle: "light",
    splash: {
      image: "./assets/splash-icon.png",
      resizeMode: "contain",
      backgroundColor: "#ffffff"
    },
    assetBundlePatterns: [
      "**/*"
    ],
    ios: {
      supportsTablet: true,
      bundleIdentifier: "com.xnose.app"
    },
    android: {
      adaptiveIcon: {
        foregroundImage: "./assets/adaptive-icon.png",
        backgroundColor: "#FFFFFF"
      },
      package: "com.xnose.app",
      permissions: [
        "android.permission.CAMERA",
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE"
      ]
    },
    web: {
      favicon: "./assets/favicon.png"
    },
    extra: {
      apiUrl: "$GATEWAY_URL",
      aiServiceUrl: "$AI_URL",
      eas: {
        projectId: "your-expo-project-id"
      }
    },
    plugins: [
      [
        "expo-camera",
        {
          cameraPermission: "Allow X-NOSE to access your camera to scan pet nose prints."
        }
      ]
    ]
  }
};
EOF
    
    print_success "Configuración de producción creada: frontend/app.config.prod.js"
}

# Actualizar archivo de configuración de API
update_api_config() {
    print_message "Actualizando configuración de API..."
    
    # Crear archivo de configuración de API para producción
    cat > ../frontend/config/api.prod.ts << EOF
// Configuración de API para producción
export const API_CONFIG = {
  BASE_URL: '$GATEWAY_URL',
  AI_SERVICE_URL: '$AI_URL',
  TIMEOUT: 30000,
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 1000,
};

export const ENDPOINTS = {
  // Auth endpoints
  LOGIN: '/api/auth/login',
  REGISTER: '/api/auth/register',
  REFRESH_TOKEN: '/api/auth/refresh',
  
  // Owner endpoints
  OWNERS: '/api/owners',
  OWNER_PROFILE: '/api/owners/profile',
  
  // Pet endpoints
  PETS: '/api/pets',
  PET_BY_ID: (id: string) => \`/api/pets/\${id}\`,
  PET_IMAGES: (id: string) => \`/api/pets/\${id}/images\`,
  
  // Alert endpoints
  ALERTS: '/api/alerts',
  ALERT_BY_ID: (id: string) => \`/api/alerts/\${id}\`,
  
  // AI endpoints
  SCAN_NOSE: '/scan',
  COMPARE_NOSE: '/compare',
  HEALTH: '/health',
};

export const HEADERS = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};
EOF
    
    print_success "Configuración de API actualizada: frontend/config/api.prod.ts"
}

# Crear script para generar APK
create_apk_script() {
    print_message "Creando script para generar APK..."
    
    cat > ../frontend/generate-apk.sh << EOF
#!/bin/bash

# 🚀 X-NOSE - Generar APK para Producción
# Este script genera el APK de la aplicación con la configuración de producción

set -e

echo "📱 Generando APK de X-NOSE para producción..."
echo "=============================================="
echo ""

# Verificar que Expo CLI esté instalado
if ! command -v expo &> /dev/null; then
    echo "❌ Expo CLI no está instalado. Instalando..."
    npm install -g @expo/cli
fi

# Verificar configuración de producción
if [ ! -f "app.config.prod.js" ]; then
    echo "❌ Configuración de producción no encontrada"
    echo "Ejecuta primero: ../gcp-deploy/scripts/update-frontend-config.sh"
    exit 1
fi

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm install

# Configurar para producción
echo "⚙️ Configurando para producción..."
export EXPO_PUBLIC_API_URL="$GATEWAY_URL"
export EXPO_PUBLIC_AI_SERVICE_URL="$AI_URL"

# Generar APK
echo "🔨 Generando APK..."
expo build:android --type apk --config app.config.prod.js

echo ""
echo "✅ APK generado exitosamente!"
echo "📁 El archivo APK se encuentra en la carpeta de descargas de Expo"
echo ""
echo "🔗 URLs de producción configuradas:"
echo "   API Gateway: $GATEWAY_URL"
echo "   AI Service: $AI_URL"
echo ""
EOF
    
    chmod +x ../frontend/generate-apk.sh
    print_success "Script de generación de APK creado: frontend/generate-apk.sh"
}

# Mostrar instrucciones finales
show_instructions() {
    print_message "Instrucciones para generar el APK:"
    
    echo ""
    echo "=== Pasos para Generar APK ==="
    echo "1. Navegar al directorio frontend:"
    echo "   cd ../../frontend"
    echo ""
    echo "2. Ejecutar el script de generación:"
    echo "   ./generate-apk.sh"
    echo ""
    echo "3. O ejecutar manualmente:"
    echo "   expo build:android --type apk --config app.config.prod.js"
    echo ""
    echo "=== URLs Configuradas ==="
    echo "Gateway: $GATEWAY_URL"
    echo "AI Service: $AI_URL"
    echo ""
    
    print_success "Configuración del frontend completada"
}

# Función principal
main() {
    echo "📱 Actualizando Configuración del Frontend"
    echo "=========================================="
    echo ""
    
    load_config
    verify_urls
    create_production_config
    update_api_config
    create_apk_script
    show_instructions
    
    echo ""
    print_success "¡Configuración del frontend actualizada!"
    echo ""
    echo "Próximo paso:"
    echo "cd ../../frontend && ./generate-apk.sh"
    echo ""
}

# Ejecutar función principal
main "$@" 