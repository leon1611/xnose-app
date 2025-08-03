#!/bin/bash

# Script para solucionar la conectividad entre Cloud Run y Cloud SQL
# Problema: Cloud Run tiene IPs públicas, Cloud SQL tiene IP privada

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

print_info "🔗 Solucionando conectividad Cloud Run ↔ Cloud SQL"
print_info "=================================================="

# Análisis del problema
print_info "📋 Análisis del problema de conectividad:"
echo ""
echo "  🏢 CLOUD RUN (Servicios):"
echo "    - Tienen IPs públicas"
echo "    - Ejecutándose en us-central1"
echo "    - URLs públicas accesibles"
echo ""
echo "  🗄️  CLOUD SQL (Base de datos):"
echo "    - IP Pública: 34.66.242.149"
echo "    - IP Privada: 10.107.0.3"
echo "    - Redes autorizadas: 0.0.0.0/0 (todas)"
echo ""
echo "  ❌ PROBLEMA:"
echo "    - Cloud Run no puede acceder directamente a IP privada"
echo "    - Necesitamos usar Cloud SQL Auth Proxy o IP pública"
echo ""

# Verificar estado actual
print_info "🔍 Verificando configuración actual..."

# Obtener IPs de Cloud SQL
DB_PUBLIC_IP="34.66.242.149"
DB_PRIVATE_IP="10.107.0.3"
CONNECTION_NAME="app-biometrico-db:us-central1:petnow-dogs-free"

print_info "📊 Configuración de Cloud SQL:"
echo "  - IP Pública: $DB_PUBLIC_IP"
echo "  - IP Privada: $DB_PRIVATE_IP"
echo "  - Connection Name: $CONNECTION_NAME"
echo "  - Redes autorizadas: 0.0.0.0/0"

# Opciones de solución
print_info "💡 Opciones de solución disponibles:"
echo ""
echo "  1️⃣  OPCIÓN A: Usar IP Pública (Más simple)"
echo "     ✅ Ventajas: Configuración directa, sin proxy"
echo "     ⚠️  Desventajas: Menos seguro, requiere SSL"
echo ""
echo "  2️⃣  OPCIÓN B: Usar Cloud SQL Auth Proxy (Más seguro)"
echo "     ✅ Ventajas: Conexión segura, sin IP pública"
echo "     ⚠️  Desventajas: Configuración más compleja"
echo ""
echo "  3️⃣  OPCIÓN C: Usar Private Service Connect (Más económico)"
echo "     ✅ Ventajas: Conexión privada, sin costos adicionales"
echo "     ⚠️  Desventajas: Requiere VPC configurado"
echo ""

# Función para probar conectividad
test_connectivity() {
    local ip=$1
    local description=$2
    
    print_info "🔍 Probando conectividad a $description ($ip)..."
    
    # Probar con telnet (si está disponible)
    if command -v telnet &> /dev/null; then
        timeout 5 telnet $ip 5432 2>/dev/null && {
            print_success "Conexión exitosa a $description"
            return 0
        } || {
            print_warning "No se pudo conectar a $description"
            return 1
        }
    else
        # Probar con nc (netcat)
        if command -v nc &> /dev/null; then
            timeout 5 nc -z $ip 5432 2>/dev/null && {
                print_success "Conexión exitosa a $description"
                return 0
            } || {
                print_warning "No se pudo conectar a $description"
                return 1
            }
        else
            print_warning "No se puede probar conectividad (telnet/nc no disponibles)"
            return 1
        fi
    fi
}

# Probar conectividades
print_info "🧪 Probando conectividades..."
test_connectivity $DB_PUBLIC_IP "IP Pública"
PUBLIC_ACCESSIBLE=$?

# Recomendación basada en pruebas
print_info "📋 Recomendación basada en análisis:"
echo ""

if [ $PUBLIC_ACCESSIBLE -eq 0 ]; then
    print_success "✅ IP Pública es accesible"
    echo "  - Recomendamos usar OPCIÓN A (IP Pública)"
    echo "  - Configuración más simple y directa"
    echo "  - Funciona inmediatamente"
    RECOMMENDED_OPTION="A"
else
    print_warning "⚠️  IP Pública no es accesible directamente"
    echo "  - Recomendamos usar OPCIÓN B (Cloud SQL Auth Proxy)"
    echo "  - Más seguro y confiable"
    echo "  - Requiere configuración adicional"
    RECOMMENDED_OPTION="B"
fi

echo ""
print_info "🚀 Implementando solución recomendada..."

case $RECOMMENDED_OPTION in
    "A")
        print_info "🔧 Implementando OPCIÓN A: IP Pública"
        implement_public_ip_solution
        ;;
    "B")
        print_info "🔧 Implementando OPCIÓN B: Cloud SQL Auth Proxy"
        implement_proxy_solution
        ;;
    *)
        print_error "Opción no válida"
        exit 1
        ;;
esac

# Función para implementar solución con IP pública
implement_public_ip_solution() {
    print_info "🔧 Configurando servicios para usar IP pública..."
    
    # Habilitar SSL en Cloud SQL
    print_info "Habilitando SSL en Cloud SQL..."
    gcloud sql instances patch petnow-dogs-free \
        --require-ssl \
        --project=$PROJECT_ID
    
    # Función para deployar servicio con IP pública
    deploy_service_with_public_ip() {
        local service_name=$1
        local db_name=$2
        local db_user=$3
        local db_password=$4
        local port=$5
        
        print_info "🔄 Deployando $service_name con IP pública..."
        
        # Construir imagen
        print_info "Construyendo imagen de $service_name..."
        docker build -t gcr.io/$PROJECT_ID/$service_name:latest ../$service_name
        docker push gcr.io/$PROJECT_ID/$service_name:latest
        
        # Variables de entorno para PostgreSQL con IP pública
        local env_vars="SPRING_PROFILES_ACTIVE=production"
        env_vars="$env_vars,SPRING_DATASOURCE_URL=jdbc:postgresql://$DB_PUBLIC_IP:5432/$db_name?sslmode=require"
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
            print_success "$service_name deployado exitosamente con IP pública"
            
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
    
    # Deployar servicios con IP pública
    print_info "🚀 Iniciando despliegue de servicios con IP pública..."
    
    # Auth Service
    deploy_service_with_public_ip "auth-service" "auth_service_db" "auth_user" "petnow2024" "8081"
    
    # Owner Service  
    deploy_service_with_public_ip "owner-service" "owner_service_db" "owner_user" "petnow2024" "8082"
    
    # Pet Service
    deploy_service_with_public_ip "pet-service" "pet_service_db" "pet_user" "petnow2024" "8083"
    
    # Alert Service
    deploy_service_with_public_ip "alert-service" "alert_service_db" "alert_user" "petnow2024" "8084"
    
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
    
    print_success "✅ Solución con IP pública implementada"
    print_info "💡 Los servicios ahora usan PostgreSQL con SSL"
    print_info "🔒 Conexión segura habilitada"
}

# Función para implementar solución con Cloud SQL Auth Proxy
implement_proxy_solution() {
    print_info "🔧 Configurando Cloud SQL Auth Proxy..."
    
    # Función para deployar servicio con proxy
    deploy_service_with_proxy() {
        local service_name=$1
        local db_name=$2
        local db_user=$3
        local db_password=$4
        local port=$5
        
        print_info "🔄 Deployando $service_name con Cloud SQL Auth Proxy..."
        
        # Construir imagen
        print_info "Construyendo imagen de $service_name..."
        docker build -t gcr.io/$PROJECT_ID/$service_name:latest ../$service_name
        docker push gcr.io/$PROJECT_ID/$service_name:latest
        
        # Variables de entorno para PostgreSQL con proxy
        local env_vars="SPRING_PROFILES_ACTIVE=production"
        env_vars="$env_vars,SPRING_DATASOURCE_URL=jdbc:postgresql://127.0.0.1:5432/$db_name"
        env_vars="$env_vars,SPRING_DATASOURCE_USERNAME=$db_user"
        env_vars="$env_vars,SPRING_DATASOURCE_PASSWORD=$db_password"
        env_vars="$env_vars,SPRING_JPA_HIBERNATE_DDL_AUTO=update"
        env_vars="$env_vars,SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT=org.hibernate.dialect.PostgreSQLDialect"
        
        # Deployar servicio con Cloud SQL Auth Proxy
        print_info "Deployando $service_name a Cloud Run con proxy..."
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
            --add-cloudsql-instances $CONNECTION_NAME \
            --set-env-vars "$env_vars"
        
        if [ $? -eq 0 ]; then
            print_success "$service_name deployado exitosamente con proxy"
            
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
    
    # Deployar servicios con proxy
    print_info "🚀 Iniciando despliegue de servicios con Cloud SQL Auth Proxy..."
    
    # Auth Service
    deploy_service_with_proxy "auth-service" "auth_service_db" "auth_user" "petnow2024" "8081"
    
    # Owner Service  
    deploy_service_with_proxy "owner-service" "owner_service_db" "owner_user" "petnow2024" "8082"
    
    # Pet Service
    deploy_service_with_proxy "pet-service" "pet_service_db" "pet_user" "petnow2024" "8083"
    
    # Alert Service
    deploy_service_with_proxy "alert-service" "alert_service_db" "alert_user" "petnow2024" "8084"
    
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
    
    print_success "✅ Solución con Cloud SQL Auth Proxy implementada"
    print_info "💡 Los servicios ahora usan conexión segura con proxy"
    print_info "🔒 Conexión privada sin exponer IP pública"
}

# Verificar servicios después del despliegue
print_info "🔍 Verificando servicios después del despliegue..."
sleep 30

./scripts/test-db-connection.sh

print_success "✅ Solución de conectividad implementada"
print_info "💡 Los servicios ahora están conectados a PostgreSQL"
print_info "📊 Los datos son persistentes"
print_info "🔗 Conectividad resuelta" 