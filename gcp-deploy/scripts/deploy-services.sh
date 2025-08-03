#!/bin/bash

# 🚀 X-NOSE - Desplegar Servicios en Google Cloud Run
# Este script despliega todos los servicios en Cloud Run

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

# Verificar que las imágenes existan
verify_images() {
    print_message "Verificando imágenes en Container Registry..."
    
    PROJECT_ID=$(gcloud config get-value project)
    REGISTRY_URL="gcr.io/$PROJECT_ID"
    
    services=("gateway-service" "auth-service" "owner-service" "pet-service" "alert-service" "ai-service")
    
    for service in "${services[@]}"; do
        local image_tag="$REGISTRY_URL/$service:latest"
        
        if ! gcloud container images describe $image_tag &> /dev/null; then
            print_error "Imagen no encontrada: $image_tag"
            print_error "Ejecuta primero: ./scripts/build-and-push.sh"
            exit 1
        fi
    done
    
    print_success "Todas las imágenes verificadas"
}

# Desplegar servicio en Cloud Run
deploy_service() {
    local service_name=$1
    local image_tag=$2
    local port=$3
    local env_vars=$4
    
    print_message "Desplegando $service_name..."
    
    # Comando base de despliegue
    local deploy_cmd="gcloud run deploy xnose-$service_name \
        --image $image_tag \
        --platform managed \
        --region $REGION \
        --port $port \
        --allow-unauthenticated \
        --memory 1Gi \
        --cpu 1 \
        --max-instances 10 \
        --timeout 300"
    
    # Agregar variables de entorno si existen
    if [ ! -z "$env_vars" ]; then
        deploy_cmd="$deploy_cmd --set-env-vars $env_vars"
    fi
    
    # Ejecutar despliegue
    eval $deploy_cmd
    
    if [ $? -eq 0 ]; then
        print_success "Servicio desplegado: $service_name"
        
        # Obtener URL del servicio
        local service_url=$(gcloud run services describe xnose-$service_name --region=$REGION --format="value(status.url)")
        echo "URL: $service_url"
        
        # Guardar URL en archivo de configuración
        update_config_url $service_name $service_url
        
    else
        print_error "Error desplegando $service_name"
        return 1
    fi
}

# Actualizar URL en archivo de configuración
update_config_url() {
    local service_name=$1
    local url=$2
    
    # Convertir service_name a variable de configuración
    local config_var=$(echo $service_name | tr '[:lower:]' '[:upper:]' | tr '-' '_')"_URL"
    
    # Actualizar archivo de configuración
            sed -i.bak "s|^$config_var=.*|$config_var=$url|" gcp-deploy/configs/gcp-config.env
    
    print_message "URL actualizada para $service_name: $url"
}

# Desplegar todos los servicios
deploy_all_services() {
    print_message "Iniciando despliegue de todos los servicios..."
    
    PROJECT_ID=$(gcloud config get-value project)
    REGISTRY_URL="gcr.io/$PROJECT_ID"
    
    # Configuración de base de datos
    DB_ENV_VARS="SPRING_DATASOURCE_URL=jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME,SPRING_DATASOURCE_USERNAME=$DB_USER,SPRING_DATASOURCE_PASSWORD=$DB_PASSWORD"
    
    # Desplegar AI Service primero (sin dependencias)
    print_message "Desplegando AI Service..."
    deploy_service "ai-service" "$REGISTRY_URL/ai-service:latest" "8000" "HOST=0.0.0.0"
    
    # Obtener URL del AI Service
    AI_URL=$(gcloud run services describe xnose-ai-service --region=$REGION --format="value(status.url)")
    
    # Desplegar Auth Service
    print_message "Desplegando Auth Service..."
    deploy_service "auth-service" "$REGISTRY_URL/auth-service:latest" "8081" "$DB_ENV_VARS,SPRING_PROFILES_ACTIVE=production"
    
    # Obtener URL del Auth Service
    AUTH_URL=$(gcloud run services describe xnose-auth-service --region=$REGION --format="value(status.url)")
    
    # Desplegar Owner Service
    print_message "Desplegando Owner Service..."
    deploy_service "owner-service" "$REGISTRY_URL/owner-service:latest" "8082" "$DB_ENV_VARS,SPRING_PROFILES_ACTIVE=production"
    
    # Obtener URL del Owner Service
    OWNER_URL=$(gcloud run services describe xnose-owner-service --region=$REGION --format="value(status.url)")
    
    # Desplegar Pet Service
    print_message "Desplegando Pet Service..."
    PET_ENV_VARS="$DB_ENV_VARS,SPRING_PROFILES_ACTIVE=production,AI_SERVICE_URL=$AI_URL,GCS_BUCKET_NAME=$GCS_BUCKET"
    deploy_service "pet-service" "$REGISTRY_URL/pet-service:latest" "8083" "$PET_ENV_VARS"
    
    # Obtener URL del Pet Service
    PET_URL=$(gcloud run services describe xnose-pet-service --region=$REGION --format="value(status.url)")
    
    # Desplegar Alert Service
    print_message "Desplegando Alert Service..."
    deploy_service "alert-service" "$REGISTRY_URL/alert-service:latest" "8084" "$DB_ENV_VARS,SPRING_PROFILES_ACTIVE=production"
    
    # Obtener URL del Alert Service
    ALERT_URL=$(gcloud run services describe xnose-alert-service --region=$REGION --format="value(status.url)")
    
    # Desplegar Gateway Service (último, con todas las URLs)
    print_message "Desplegando Gateway Service..."
    GATEWAY_ENV_VARS="SPRING_PROFILES_ACTIVE=production,AUTH_SERVICE_URL=$AUTH_URL,OWNER_SERVICE_URL=$OWNER_URL,PET_SERVICE_URL=$PET_URL,ALERT_SERVICE_URL=$ALERT_URL,AI_SERVICE_URL=$AI_URL"
    deploy_service "gateway-service" "$REGISTRY_URL/gateway-service:latest" "8080" "$GATEWAY_ENV_VARS"
    
    # Obtener URL del Gateway Service
    GATEWAY_URL=$(gcloud run services describe xnose-gateway-service --region=$REGION --format="value(status.url)")
    
    print_success "Todos los servicios han sido desplegados"
}

# Verificar servicios desplegados
verify_deployment() {
    print_message "Verificando servicios desplegados..."
    
    echo ""
    echo "=== Servicios Desplegados ==="
    gcloud run services list --region=$REGION --format="table(metadata.name,status.url,status.conditions[0].status)"
    
    print_success "Verificación completada"
}

# Mostrar URLs finales
show_final_urls() {
    print_message "URLs de los servicios desplegados:"
    
    echo ""
    echo "=== URLs de Servicios ==="
    echo "Gateway: $(gcloud run services describe xnose-gateway-service --region=$REGION --format="value(status.url)")"
    echo "Auth: $(gcloud run services describe xnose-auth-service --region=$REGION --format="value(status.url)")"
    echo "Owner: $(gcloud run services describe xnose-owner-service --region=$REGION --format="value(status.url)")"
    echo "Pet: $(gcloud run services describe xnose-pet-service --region=$REGION --format="value(status.url)")"
    echo "Alert: $(gcloud run services describe xnose-alert-service --region=$REGION --format="value(status.url)")"
    echo "AI: $(gcloud run services describe xnose-ai-service --region=$REGION --format="value(status.url)")"
    echo ""
    
    print_success "Despliegue completado exitosamente"
}

# Función principal
main() {
    echo "🚀 Desplegando Servicios en Google Cloud Run"
    echo "============================================"
    echo ""
    
    load_config
    verify_images
    deploy_all_services
    verify_deployment
    show_final_urls
    
    echo ""
    print_success "¡Despliegue completado!"
    echo ""
    echo "Próximos pasos:"
    echo "1. Actualizar frontend con las nuevas URLs"
    echo "2. Generar APK: expo build:android --type apk"
    echo "3. Probar servicios: ./scripts/monitor-services.sh"
    echo ""
}

# Ejecutar función principal
main "$@" 