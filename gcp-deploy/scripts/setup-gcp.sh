#!/bin/bash

# 🚀 X-NOSE - Configuración de Google Cloud Platform
# Este script configura GCP para el despliegue de X-NOSE

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

# Verificar que gcloud esté instalado
check_gcloud() {
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud CLI no está instalado. Por favor instálalo primero:"
        echo "https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    print_success "Google Cloud CLI detectado"
}

# Verificar autenticación
check_auth() {
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_warning "No hay sesión activa de Google Cloud"
        gcloud auth login
    fi
    print_success "Autenticación verificada"
}

# Configurar proyecto
setup_project() {
    print_message "Configurando proyecto de Google Cloud..."
    
    # Obtener PROJECT_ID actual
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "")
    
    if [ -z "$CURRENT_PROJECT" ]; then
        print_warning "No hay proyecto configurado"
        echo "Proyectos disponibles:"
        gcloud projects list --format="table(projectId,name)"
        echo ""
        read -p "Ingresa el PROJECT_ID: " PROJECT_ID
        gcloud config set project $PROJECT_ID
    else
        print_message "Proyecto actual: $CURRENT_PROJECT"
        read -p "¿Usar este proyecto? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Proyectos disponibles:"
            gcloud projects list --format="table(projectId,name)"
            echo ""
            read -p "Ingresa el PROJECT_ID: " PROJECT_ID
            gcloud config set project $PROJECT_ID
        fi
    fi
    
    PROJECT_ID=$(gcloud config get-value project)
    print_success "Proyecto configurado: $PROJECT_ID"
}

# Habilitar APIs necesarias
enable_apis() {
    print_message "Habilitando APIs necesarias..."
    
    APIs=(
        "run.googleapis.com"
        "cloudbuild.googleapis.com"
        "containerregistry.googleapis.com"
        "sqladmin.googleapis.com"
        "storage.googleapis.com"
        "compute.googleapis.com"
        "cloudresourcemanager.googleapis.com"
    )
    
    for api in "${APIs[@]}"; do
        print_message "Habilitando $api..."
        gcloud services enable $api --quiet
    done
    
    print_success "APIs habilitadas"
}

# Configurar región
setup_region() {
    print_message "Configurando región..."
    
    # Usar us-central1 por defecto (más barata)
    REGION="us-central1"
    gcloud config set run/region $REGION
    gcloud config set compute/region $REGION
    
    print_success "Región configurada: $REGION"
}

# Configurar Container Registry
setup_container_registry() {
    print_message "Configurando Container Registry..."
    
    # Configurar Docker para usar gcloud como helper
    gcloud auth configure-docker --quiet
    
    print_success "Container Registry configurado"
}

# Crear archivo de configuración
create_config() {
    print_message "Creando archivo de configuración..."
    
    PROJECT_ID=$(gcloud config get-value project)
    REGION=$(gcloud config get-value run/region)
    
    cat > configs/gcp-config.env << EOF
# Configuración de Google Cloud Platform
PROJECT_ID=$PROJECT_ID
REGION=$REGION
REGISTRY_URL=gcr.io/$PROJECT_ID

# URLs de servicios (se llenarán después del despliegue)
GATEWAY_URL=
AUTH_URL=
OWNER_URL=
PET_URL=
ALERT_URL=
AI_URL=

# Base de datos (ya configurada)
DB_HOST=34.66.242.149
DB_PORT=5432
DB_NAME=auth_service_db
DB_USER=auth_user
DB_PASSWORD=tu_password_aqui

# Google Cloud Storage
GCS_BUCKET=petnow-dogs-images-$PROJECT_ID
EOF
    
    print_success "Archivo de configuración creado: configs/gcp-config.env"
    print_warning "Recuerda actualizar las credenciales de la base de datos en el archivo"
}

# Verificar configuración
verify_setup() {
    print_message "Verificando configuración..."
    
    PROJECT_ID=$(gcloud config get-value project)
    REGION=$(gcloud config get-value run/region)
    
    echo ""
    echo "=== Configuración de Google Cloud ==="
    echo "Proyecto: $PROJECT_ID"
    echo "Región: $REGION"
    echo "Container Registry: gcr.io/$PROJECT_ID"
    echo ""
    
    # Verificar APIs
    echo "APIs habilitadas:"
    gcloud services list --enabled --filter="name:run.googleapis.com OR name:cloudbuild.googleapis.com OR name:containerregistry.googleapis.com" --format="table(name)"
    
    print_success "Configuración verificada"
}

# Función principal
main() {
    echo "🚀 Configurando Google Cloud Platform para X-NOSE"
    echo "=================================================="
    echo ""
    
    check_gcloud
    check_auth
    setup_project
    enable_apis
    setup_region
    setup_container_registry
    create_config
    verify_setup
    
    echo ""
    print_success "¡Configuración de Google Cloud completada!"
    echo ""
    echo "Próximos pasos:"
    echo "1. Actualizar credenciales de BD en configs/gcp-config.env"
    echo "2. Ejecutar: ./scripts/build-and-push.sh"
    echo "3. Ejecutar: ./scripts/deploy-services.sh"
    echo ""
}

# Ejecutar función principal
main "$@" 