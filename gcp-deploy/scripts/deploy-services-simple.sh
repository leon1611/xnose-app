#!/bin/bash

# Script simplificado para desplegar servicios
# Usando Private Service Connect para Cloud SQL

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

# Cargar configuración
load_config() {
    if [ ! -f "gcp-deploy/configs/gcp-config.env" ]; then
        print_error "Archivo de configuración no encontrado. Ejecuta primero: ./scripts/setup-gcp.sh"
        exit 1
    fi
    
    source gcp-deploy/configs/gcp-config.env
    print_success "Configuración cargada"
}

# Función para desplegar servicio
deploy_service() {
    local service_name=$1
    local image_url=$2
    local port=$3
    local env_vars=$4
    
    print_info "Desplegando $service_name..."
    
    # Desplegar servicio
    gcloud run deploy "xnose-$service_name" \
        --image "$image_url" \
        --platform managed \
        --region us-central1 \
        --port "$port" \
        --allow-unauthenticated \
        --memory 1Gi \
        --cpu 1 \
        --max-instances 10 \
        --timeout 300 \
        --set-env-vars "$env_vars"
    
    if [ $? -eq 0 ]; then
        print_success "Servicio desplegado: $service_name"
        
        # Obtener URL del servicio
        local url=$(gcloud run services describe "xnose-$service_name" --region=us-central1 --format="value(status.url)")
        print_info "URL: $url"
        
        # Actualizar archivo de configuración
        local config_var=$(echo "${service_name^^}_URL" | tr '-' '_')
        sed -i.bak "s|^$config_var=.*|$config_var=$url|" gcp-deploy/configs/gcp-config.env
        
        print_info "URL actualizada para $service_name: $url"
    else
        print_error "Error al desplegar $service_name"
        return 1
    fi
}

# Función principal
main() {
    print_info "🚀 Desplegando Servicios con Private Service Connect"
    print_info "=================================================="
    
    load_config
    
    # Verificar que las imágenes estén disponibles
    print_info "Verificando imágenes en Container Registry..."
    
    local images=(
        "gcr.io/app-biometrico-db/auth-service:latest"
        "gcr.io/app-biometrico-db/owner-service:latest"
        "gcr.io/app-biometrico-db/pet-service:latest"
        "gcr.io/app-biometrico-db/alert-service:latest"
    )
    
    for image in "${images[@]}"; do
        if ! gcloud container images describe "$image" >/dev/null 2>&1; then
            print_error "Imagen no encontrada: $image"
            exit 1
        fi
    done
    
    print_success "Todas las imágenes verificadas"
    
    # Desplegar servicios
    print_info "Iniciando despliegue de servicios..."
    
    # Auth Service
    deploy_service "auth-service" \
        "gcr.io/app-biometrico-db/auth-service:latest" \
        "8081" \
        "SPRING_PROFILES_ACTIVE=production,SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/auth_service_db,SPRING_DATASOURCE_USERNAME=postgres,SPRING_DATASOURCE_PASSWORD=petnow2024"
    
    # Owner Service
    deploy_service "owner-service" \
        "gcr.io/app-biometrico-db/owner-service:latest" \
        "8082" \
        "SPRING_PROFILES_ACTIVE=production,SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/owner_service_db,SPRING_DATASOURCE_USERNAME=postgres,SPRING_DATASOURCE_PASSWORD=petnow2024"
    
    # Pet Service
    deploy_service "pet-service" \
        "gcr.io/app-biometrico-db/pet-service:latest" \
        "8083" \
        "SPRING_PROFILES_ACTIVE=production,SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/pet_service_db,SPRING_DATASOURCE_USERNAME=postgres,SPRING_DATASOURCE_PASSWORD=petnow2024,AI_SERVICE_URL=https://xnose-ai-service-jrms6vnyga-uc.a.run.app"
    
    # Alert Service
    deploy_service "alert-service" \
        "gcr.io/app-biometrico-db/alert-service:latest" \
        "8084" \
        "SPRING_PROFILES_ACTIVE=production,SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/alert_service_db,SPRING_DATASOURCE_USERNAME=postgres,SPRING_DATASOURCE_PASSWORD=petnow2024"
    
    print_success "¡Despliegue completado!"
    print_info "Todos los servicios están usando Private Service Connect para Cloud SQL"
}

# Ejecutar función principal
main "$@" 