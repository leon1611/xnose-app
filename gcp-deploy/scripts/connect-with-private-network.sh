#!/bin/bash

# Script para conectar servicios a PostgreSQL usando la red privada de Google Cloud
# Usa la autorización de servicios de Google Cloud para conexión directa

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
if [ -f "configs/gcp-config.env" ]; then
    source configs/gcp-config.env
else
    print_error "No se encontró configs/gcp-config.env"
    exit 1
fi

print_info "🔗 Conectando servicios a PostgreSQL usando red privada de Google Cloud"
print_info "======================================================================"

# Verificar estado de la instancia
print_info "Verificando estado de la instancia de base de datos..."
INSTANCE_STATE=$(gcloud sql instances describe petnow-dogs-free --project=$PROJECT_ID --format="value(state)")

if [ "$INSTANCE_STATE" != "RUNNABLE" ]; then
    print_error "La instancia no está ejecutándose. Estado: $INSTANCE_STATE"
    exit 1
fi

print_success "Instancia ejecutándose correctamente"

# Verificar configuración de red privada
print_info "Verificando configuración de red privada..."
PRIVATE_NETWORK=$(gcloud sql instances describe petnow-dogs-free --project=$PROJECT_ID --format="value(settings.ipConfiguration.privateNetwork)")
AUTHORIZED_APPS=$(gcloud sql instances describe petnow-dogs-free --project=$PROJECT_ID --format="value(settings.ipConfiguration.authorizedGaeApplications)")

print_info "📋 Configuración de red:"
echo "  - Red privada: $PRIVATE_NETWORK"
echo "  - Apps autorizadas: $AUTHORIZED_APPS"
echo "  - Proyecto: $PROJECT_ID"

if [[ "$AUTHORIZED_APPS" == *"$PROJECT_ID"* ]]; then
    print_success "✅ Autorización de servicios de Google Cloud habilitada"
else
    print_warning "⚠️  Autorización de servicios no configurada correctamente"
    print_info "Habilitando autorización de servicios..."
    gcloud sql instances patch petnow-dogs-free --authorized-gae-apps=$PROJECT_ID --project=$PROJECT_ID
    print_success "✅ Autorización habilitada"
fi

# Obtener IP privada
DB_PRIVATE_IP=$(gcloud sql instances describe petnow-dogs-free --project=$PROJECT_ID --format="json" | grep -A 1 '"type": "PRIVATE"' | grep "ipAddress" | cut -d'"' -f4)

if [ -z "$DB_PRIVATE_IP" ]; then
    # Intentar método alternativo
    DB_PRIVATE_IP=$(gcloud sql instances describe petnow-dogs-free --project=$PROJECT_ID --format="json" | grep -B 1 '"type": "PRIVATE"' | grep "ipAddress" | cut -d'"' -f4)
fi

if [ -z "$DB_PRIVATE_IP" ]; then
    print_error "No se pudo obtener la IP privada"
    print_info "Usando IP privada conocida: 10.107.0.3"
    DB_PRIVATE_IP="10.107.0.3"
fi

print_info "📊 Configuración de conexión:"
echo "  - IP Privada: $DB_PRIVATE_IP"
echo "  - Puerto: 5432"
echo "  - Red: Google Cloud Private Network"
echo "  - Seguridad: Alta (conexión interna)"

# Función para deployar servicio con red privada
deploy_service_with_private_network() {
    local service_name=$1
    local db_name=$2
    local db_user=$3
    local db_password=$4
    local port=$5
    
    print_info "🔄 Deployando $service_name con red privada..."
    
    # Construir imagen
    print_info "Construyendo imagen de $service_name..."
    docker build -t gcr.io/$PROJECT_ID/$service_name:latest ../$service_name
    docker push gcr.io/$PROJECT_ID/$service_name:latest
    
    # Variables de entorno para PostgreSQL con red privada
    local env_vars="SPRING_PROFILES_ACTIVE=production"
    env_vars="$env_vars,SPRING_DATASOURCE_URL=jdbc:postgresql://$DB_PRIVATE_IP:5432/$db_name"
    env_vars="$env_vars,SPRING_DATASOURCE_USERNAME=$db_user"
    env_vars="$env_vars,SPRING_DATASOURCE_PASSWORD=$db_password"
    env_vars="$env_vars,SPRING_JPA_HIBERNATE_DDL_AUTO=update"
    env_vars="$env_vars,SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT=org.hibernate.dialect.PostgreSQLDialect"
    
    # Deployar servicio
    print_info "Deployando $service_name a Cloud Run..."
    gcloud run deploy xnose-$service_name \
        --image gcr.io/$PROJECT_ID/$service_name:latest \
        --platform managed \
        --region $REGION \
        --port $port \
        --allow-unauthenticated \
        --memory 512Mi \
        --cpu 1 \
        --max-instances 3 \
        --min-instances 0 \
        --timeout 300 \
        --set-env-vars "$env_vars"
    
    if [ $? -eq 0 ]; then
        print_success "$service_name deployado exitosamente con red privada"
        
        # Obtener nueva URL
        local new_url=$(gcloud run services describe xnose-$service_name --region=$REGION --format="value(status.url)")
        print_info "Nueva URL: $new_url"
        
        # Actualizar configuración
        update_config_url $service_name $new_url
    else
        print_error "Error al deployar $service_name"
        return 1
    fi
}

# Función para actualizar URL en configuración
update_config_url() {
    local service_name=$1
    local new_url=$2
    
    case $service_name in
        "auth-service")
            sed -i '' "s|^AUTH_URL=.*|AUTH_URL=$new_url|" configs/gcp-config.env
            ;;
        "owner-service")
            sed -i '' "s|^OWNER_URL=.*|OWNER_URL=$new_url|" configs/gcp-config.env
            ;;
        "pet-service")
            sed -i '' "s|^PET_URL=.*|PET_URL=$new_url|" configs/gcp-config.env
            ;;
        "alert-service")
            sed -i '' "s|^ALERT_URL=.*|ALERT_URL=$new_url|" configs/gcp-config.env
            ;;
    esac
}

# Deployar servicios con red privada
print_info "🚀 Iniciando despliegue de servicios con red privada..."

# Auth Service
deploy_service_with_private_network "auth-service" "auth_service_db" "auth_user" "petnow2024" "8081"

# Owner Service  
deploy_service_with_private_network "owner-service" "owner_service_db" "owner_user" "petnow2024" "8082"

# Pet Service
deploy_service_with_private_network "pet-service" "pet_service_db" "pet_user" "petnow2024" "8083"

# Alert Service
deploy_service_with_private_network "alert-service" "alert_service_db" "alert_user" "petnow2024" "8084"

# Actualizar Gateway con nuevas URLs
print_info "🔄 Actualizando Gateway Service con nuevas URLs..."
source configs/gcp-config.env

gcloud run deploy xnose-gateway-service \
    --image gcr.io/$PROJECT_ID/gateway-service:latest \
    --platform managed \
    --region $REGION \
    --port 8080 \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 3 \
    --min-instances 0 \
    --timeout 300 \
    --set-env-vars "SPRING_PROFILES_ACTIVE=production,AUTH_SERVICE_URL=$AUTH_URL,OWNER_SERVICE_URL=$OWNER_URL,PET_SERVICE_URL=$PET_URL,ALERT_SERVICE_URL=$ALERT_URL,AI_SERVICE_URL=$AI_URL"

# Verificar servicios
print_info "🔍 Verificando servicios después del despliegue..."
sleep 30

./scripts/test-db-connection.sh

print_success "✅ Conexión con red privada completada"
print_info "💡 Los servicios ahora usan PostgreSQL con conexión privada"
print_info "📊 Los datos son persistentes"
print_info "🔒 Conexión segura a través de la red interna de Google Cloud"
print_info "💰 Sin costos adicionales de proxy o IP pública"
print_info "🔗 Problema de conectividad resuelto de manera óptima" 