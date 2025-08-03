#!/bin/bash

# 🚀 X-NOSE - Construir y Subir Imágenes Docker
# Este script construye y sube todas las imágenes a Google Container Registry

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

# Verificar Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado. Por favor instálalo primero."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker no está ejecutándose. Por favor inicia Docker."
        exit 1
    fi
    
    print_success "Docker verificado"
}

# Verificar autenticación de Google Cloud
check_gcloud_auth() {
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "No hay sesión activa de Google Cloud. Ejecuta: gcloud auth login"
        exit 1
    fi
    
    print_success "Autenticación de Google Cloud verificada"
}

# Construir imagen Docker
build_image() {
    local service_name=$1
    local dockerfile_path=$2
    local image_tag=$3
    
    print_message "Construyendo imagen para $service_name..."
    
    # Verificar que existe el Dockerfile
    if [ ! -f "$dockerfile_path/Dockerfile" ]; then
        print_error "Dockerfile no encontrado en: $dockerfile_path/Dockerfile"
        return 1
    fi
    
    # Construir imagen
    docker build -t $image_tag $dockerfile_path
    
    if [ $? -eq 0 ]; then
        print_success "Imagen construida: $image_tag"
    else
        print_error "Error construyendo imagen: $image_tag"
        return 1
    fi
}

# Subir imagen a Google Container Registry
push_image() {
    local image_tag=$1
    
    print_message "Subiendo imagen: $image_tag"
    
    docker push $image_tag
    
    if [ $? -eq 0 ]; then
        print_success "Imagen subida: $image_tag"
    else
        print_error "Error subiendo imagen: $image_tag"
        return 1
    fi
}

# Construir y subir todas las imágenes
build_and_push_all() {
    print_message "Iniciando construcción y subida de imágenes..."
    
    # Obtener PROJECT_ID
    PROJECT_ID=$(gcloud config get-value project)
    REGISTRY_URL="gcr.io/$PROJECT_ID"
    
    # Definir servicios
    services=("gateway-service" "auth-service" "owner-service" "pet-service" "alert-service" "ai-service")
    paths=("gateway-service" "auth-service" "owner-service" "pet-service" "alert-service" "ai-service")
    
    # Construir y subir cada servicio
    for i in "${!services[@]}"; do
        local service="${services[$i]}"
        local service_path="${paths[$i]}"
        local image_tag="$REGISTRY_URL/$service:latest"
        
        print_message "Procesando $service..."
        
        # Construir imagen
        if build_image "$service" "$service_path" "$image_tag"; then
            # Subir imagen
            push_image "$image_tag"
        else
            print_error "Error procesando $service"
            return 1
        fi
        
        echo ""
    done
    
    print_success "Todas las imágenes han sido construidas y subidas"
}

# Verificar imágenes subidas
verify_images() {
    print_message "Verificando imágenes en Google Container Registry..."
    
    PROJECT_ID=$(gcloud config get-value project)
    
    echo ""
    echo "=== Imágenes disponibles ==="
    gcloud container images list --repository=gcr.io/$PROJECT_ID --format="table(name,tags)"
    
    print_success "Verificación completada"
}

# Función principal
main() {
    echo "🐳 Construyendo y Subiendo Imágenes Docker"
    echo "=========================================="
    echo ""
    
    load_config
    check_docker
    check_gcloud_auth
    build_and_push_all
    verify_images
    
    echo ""
    print_success "¡Construcción y subida de imágenes completada!"
    echo ""
    echo "Próximo paso:"
    echo "Ejecutar: ./scripts/deploy-services.sh"
    echo ""
}

# Ejecutar función principal
main "$@" 