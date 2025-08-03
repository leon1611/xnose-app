#!/bin/bash

# Script económico para desplegar servicios con Cloud SQL Auth Proxy
# Optimizado para mantener costos bajos

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

# Función para desplegar servicio económico
deploy_service_economico() {
    local service_name=$1
    local image_url=$2
    local port=$3
    local db_name=$4
    local env_vars=$5
    
    print_info "Desplegando $service_name (configuración económica)..."
    
    # Configuración económica: menos recursos, más instancias
    gcloud run deploy "xnose-$service_name" \
        --image "$image_url" \
        --platform managed \
        --region us-central1 \
        --port "$port" \
        --allow-unauthenticated \
        --memory 256Mi \
        --cpu 0.25 \
        --max-instances 3 \
        --min-instances 0 \
        --timeout 300 \
        --add-cloudsql-instances "app-biometrico-db:us-central1:petnow-dogs-free" \
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
    print_info "🚀 Desplegando Servicios (Configuración Económica)"
    print_info "================================================"
    
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
    
    # Desplegar servicios con configuración económica
    print_info "Iniciando despliegue de servicios (configuración económica)..."
    
    # Auth Service - con Cloud SQL Auth Proxy
    deploy_service_economico "auth-service" \
        "gcr.io/app-biometrico-db/auth-service:latest" \
        "8081" \
        "auth_service_db" \
        "SPRING_PROFILES_ACTIVE=production,SPRING_DATASOURCE_URL=jdbc:postgresql://127.0.0.1:5432/auth_service_db,SPRING_DATASOURCE_USERNAME=auth_user,SPRING_DATASOURCE_PASSWORD=leon1611"
    
    # Owner Service - con Cloud SQL Auth Proxy
    deploy_service_economico "owner-service" \
        "gcr.io/app-biometrico-db/owner-service:latest" \
        "8082" \
        "owner_service_db" \
        "SPRING_PROFILES_ACTIVE=production,SPRING_DATASOURCE_URL=jdbc:postgresql://127.0.0.1:5432/owner_service_db,SPRING_DATASOURCE_USERNAME=owner_user,SPRING_DATASOURCE_PASSWORD=leon1611"
    
    # Pet Service - con Cloud SQL Auth Proxy
    deploy_service_economico "pet-service" \
        "gcr.io/app-biometrico-db/pet-service:latest" \
        "8083" \
        "pet_service_db" \
        "SPRING_PROFILES_ACTIVE=production,SPRING_DATASOURCE_URL=jdbc:postgresql://127.0.0.1:5432/pet_service_db,SPRING_DATASOURCE_USERNAME=pet_user,SPRING_DATASOURCE_PASSWORD=leon1611,AI_SERVICE_URL=https://xnose-ai-service-jrms6vnyga-uc.a.run.app"
    
    # Alert Service - con Cloud SQL Auth Proxy
    deploy_service_economico "alert-service" \
        "gcr.io/app-biometrico-db/alert-service:latest" \
        "8084" \
        "alert_service_db" \
        "SPRING_PROFILES_ACTIVE=production,SPRING_DATASOURCE_URL=jdbc:postgresql://127.0.0.1:5432/alert_service_db,SPRING_DATASOURCE_USERNAME=alert_user,SPRING_DATASOURCE_PASSWORD=leon1611"
    
    print_success "¡Despliegue económico completado!"
    print_info "Configuración optimizada para costos bajos:"
    print_info "- Memoria: 256Mi por servicio"
    print_info "- CPU: 0.25 vCPU por servicio"
    print_info "- Máximo 3 instancias por servicio"
    print_info "- Mínimo 0 instancias (escala a cero)"
    print_info "- Cloud SQL Auth Proxy (gratuito y seguro)"
}

# Ejecutar función principal
main "$@" 