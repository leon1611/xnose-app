#!/bin/bash

# Script para generar variables de entorno para Render - XNOSE
# Este script te ayuda a generar las variables de entorno necesarias

echo "🚀 Generador de Variables de Entorno para XNOSE en Render"
echo "=================================================="
echo ""

# Función para generar JWT Secret
generate_jwt_secret() {
    echo "🔐 Generando JWT Secret..."
    JWT_SECRET=$(openssl rand -base64 64 | tr -d "=+/" | cut -c1-64)
    echo "JWT_SECRET generado: $JWT_SECRET"
    echo ""
}

# Función para solicitar información de Google Cloud
get_gcs_info() {
    echo "☁️  Configuración de Google Cloud Storage"
    echo "----------------------------------------"
    read -p "Ingresa el nombre de tu bucket de GCS: " GCS_BUCKET_NAME
    read -p "Ingresa el ID de tu proyecto de Google Cloud: " GOOGLE_CLOUD_PROJECT
    echo ""
    
    echo "📁 Configuración del archivo de credenciales"
    echo "--------------------------------------------"
    echo "Para obtener las credenciales de servicio:"
    echo "1. Ve a Google Cloud Console"
    echo "2. Navega a IAM & Admin > Service Accounts"
    echo "3. Crea una nueva cuenta de servicio o usa una existente"
    echo "4. Crea una nueva clave (JSON)"
    echo "5. Descarga el archivo JSON"
    echo ""
    read -p "¿Tienes el archivo JSON de credenciales? (y/n): " has_credentials
    
    if [ "$has_credentials" = "y" ] || [ "$has_credentials" = "Y" ]; then
        read -p "Ingresa la ruta al archivo JSON de credenciales: " credentials_file
        if [ -f "$credentials_file" ]; then
            GOOGLE_APPLICATION_CREDENTIALS=$(cat "$credentials_file")
            echo "✅ Credenciales cargadas correctamente"
        else
            echo "❌ Archivo no encontrado"
            GOOGLE_APPLICATION_CREDENTIALS=""
        fi
    else
        echo "⚠️  Deberás configurar las credenciales manualmente en Render"
        GOOGLE_APPLICATION_CREDENTIALS=""
    fi
    echo ""
}

# Función para generar el archivo de variables
generate_env_file() {
    echo "📝 Generando archivo de variables de entorno..."
    
    cat > render-env-variables.txt << EOF
# Variables de Entorno para XNOSE en Render
# Generado el: $(date)
# ================================================

# 🔐 JWT Configuration
JWT_SECRET=$JWT_SECRET
JWT_EXPIRATION=86400000

# ☁️ Google Cloud Storage
GCS_BUCKET_NAME=$GCS_BUCKET_NAME
GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT
GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS

# 🌐 Frontend Configuration
EXPO_PUBLIC_GCS_BUCKET_URL=https://storage.googleapis.com/$GCS_BUCKET_NAME

# 📊 Logging
LOG_LEVEL=INFO

# 🤖 AI Service Configuration
SIMILARITY_THRESHOLD=0.80
CONFIDENCE_BOOST=0.1
EMBEDDINGS_FILE=nose_print_embeddings.json
AUDIT_LOG_FILE=requests.log
CORS_ORIGINS=https://*.onrender.com,https://*.vercel.app,http://localhost:19000,http://localhost:3000

# 🔧 Service Configuration
AI_SERVICE_ENABLED=true
GCS_ENABLED=true
NODE_ENV=production

# ================================================
# INSTRUCCIONES PARA CONFIGURAR EN RENDER:
# ================================================
# 1. Ve a cada servicio en Render Dashboard
# 2. Navega a la sección "Environment"
# 3. Agrega las variables que correspondan a cada servicio
# 4. Las variables de base de datos se configuran automáticamente
# 5. Las URLs de los servicios se configuran automáticamente en render.yaml
# ================================================
EOF

    echo "✅ Archivo 'render-env-variables.txt' generado"
    echo ""
}

# Función para mostrar resumen
show_summary() {
    echo "📋 Resumen de Configuración"
    echo "=========================="
    echo "JWT Secret: ${JWT_SECRET:0:20}..."
    echo "GCS Bucket: $GCS_BUCKET_NAME"
    echo "GCP Project: $GOOGLE_CLOUD_PROJECT"
    echo "GCS Bucket URL: https://storage.googleapis.com/$GCS_BUCKET_NAME"
    echo ""
    echo "📁 Archivo generado: render-env-variables.txt"
    echo ""
}

# Función para mostrar instrucciones de Render
show_render_instructions() {
    echo "🎯 Instrucciones para Render"
    echo "==========================="
    echo ""
    echo "1. 📊 Crear Base de Datos:"
    echo "   - Ve a Render Dashboard > Databases"
    echo "   - Crea una nueva base de datos PostgreSQL"
    echo "   - Las variables de BD se configuran automáticamente"
    echo ""
    echo "2. 🔧 Configurar Variables por Servicio:"
    echo "   - Gateway Service: JWT_SECRET, JWT_EXPIRATION, LOG_LEVEL"
    echo "   - Auth Service: JWT_SECRET, JWT_EXPIRATION, LOG_LEVEL"
    echo "   - Owner Service: JWT_SECRET, JWT_EXPIRATION, LOG_LEVEL"
    echo "   - Pet Service: JWT_SECRET, JWT_EXPIRATION, LOG_LEVEL, GCS_*"
    echo "   - Alert Service: JWT_SECRET, JWT_EXPIRATION, LOG_LEVEL"
    echo "   - AI Service: Todas las variables de GCS y configuración"
    echo "   - Frontend: EXPO_PUBLIC_GCS_BUCKET_URL"
    echo ""
    echo "3. 🔐 Variables Sensibles (sync: false):"
    echo "   - JWT_SECRET"
    echo "   - GCS_BUCKET_NAME"
    echo "   - GOOGLE_CLOUD_PROJECT"
    echo "   - GOOGLE_APPLICATION_CREDENTIALS"
    echo "   - EXPO_PUBLIC_GCS_BUCKET_URL"
    echo ""
    echo "4. 🚀 Desplegar:"
    echo "   - Conecta tu repositorio de GitHub a Render"
    echo "   - Render detectará automáticamente el render.yaml"
    echo "   - Configura las variables de entorno antes del primer deploy"
    echo ""
}

# Ejecutar el script
main() {
    generate_jwt_secret
    get_gcs_info
    generate_env_file
    show_summary
    show_render_instructions
    
    echo "🎉 ¡Configuración completada!"
    echo "Revisa el archivo 'render-env-variables.txt' para ver todas las variables"
}

# Ejecutar función principal
main 