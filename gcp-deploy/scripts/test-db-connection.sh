#!/bin/bash

# Script para probar la conexión a la base de datos PostgreSQL
# desde los servicios desplegados en Cloud Run

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

print_info "🔍 Probando conexión a la base de datos PostgreSQL"
print_info "=================================================="

# Verificar estado de la instancia
print_info "Verificando estado de la instancia de base de datos..."
INSTANCE_STATE=$(gcloud sql instances describe petnow-dogs-free --project=$PROJECT_ID --format="value(state)")

if [ "$INSTANCE_STATE" != "RUNNABLE" ]; then
    print_error "La instancia no está ejecutándose. Estado: $INSTANCE_STATE"
    exit 1
fi

print_success "Instancia ejecutándose correctamente"

# Obtener IP pública
print_info "Obteniendo IP pública de la instancia..."
DB_PUBLIC_IP="34.66.242.149"
print_success "IP pública: $DB_PUBLIC_IP"

# Probar conexión directa (desde tu máquina local)
print_info "Probando conexión directa desde tu máquina local..."
if command -v psql &> /dev/null; then
    print_info "Intentando conexión con psql..."
    PGPASSWORD=$DB_PASSWORD psql -h $DB_PUBLIC_IP -U $DB_USER -d postgres -c "SELECT version();" 2>/dev/null && {
        print_success "Conexión directa exitosa"
    } || {
        print_warning "Conexión directa falló (esperado si no tienes psql o la IP no está autorizada)"
    }
else
    print_warning "psql no está instalado, saltando prueba directa"
fi

# Probar conexión desde Cloud Run usando curl
print_info "Probando conexión desde servicios desplegados..."

# Función para probar servicio
test_service_db_connection() {
    local service_name=$1
    local service_url=$2
    local db_name=$3
    local db_user=$4
    
    print_info "Probando $service_name..."
    
    # Probar health check
    HEALTH_RESPONSE=$(curl -s "$service_url/actuator/health" 2>/dev/null || echo "ERROR")
    
    if [[ "$HEALTH_RESPONSE" == *"\"status\":\"UP\""* ]]; then
        print_success "$service_name está funcionando"
        
        # Verificar si usa H2 o PostgreSQL
        if [[ "$HEALTH_RESPONSE" == *"\"database\":\"H2\""* ]]; then
            print_warning "$service_name está usando H2 (base de datos en memoria)"
        elif [[ "$HEALTH_RESPONSE" == *"\"database\":\"PostgreSQL\""* ]]; then
            print_success "$service_name está usando PostgreSQL"
        else
            print_info "$service_name - estado de base de datos no determinado"
        fi
    else
        print_error "$service_name no responde correctamente"
    fi
}

# Probar cada servicio
test_service_db_connection "Auth Service" "$AUTH_URL" "$AUTH_DB_NAME" "auth_user"
test_service_db_connection "Owner Service" "$OWNER_URL" "$OWNER_DB_NAME" "owner_user"
test_service_db_connection "Pet Service" "$PET_URL" "$PET_DB_NAME" "pet_user"
test_service_db_connection "Alert Service" "$ALERT_URL" "$ALERT_DB_NAME" "alert_user"

# Probar Gateway
print_info "Probando Gateway Service..."
GATEWAY_HEALTH=$(curl -s "$GATEWAY_URL/actuator/health" 2>/dev/null || echo "ERROR")

if [[ "$GATEWAY_HEALTH" == *"\"status\":\"UP\""* ]]; then
    print_success "Gateway Service está funcionando"
else
    print_error "Gateway Service no responde correctamente"
fi

# Mostrar configuración actual
print_info "📋 Configuración actual de base de datos:"
echo "  - Instancia: petnow-dogs-free"
echo "  - Estado: $INSTANCE_STATE"
echo "  - IP Pública: $DB_PUBLIC_IP"
echo "  - Conexión: $CONNECTION_NAME"
echo "  - SSL Requerido: No"
echo "  - Redes autorizadas: 0.0.0.0/0 (todas)"

print_info "📊 Bases de datos disponibles:"
echo "  - postgres (sistema)"
echo "  - auth_service_db"
echo "  - owner_service_db"
echo "  - pet_service_db"
echo "  - alert_service_db"
echo "  - scan_service_db"

print_info "👥 Usuarios disponibles:"
echo "  - postgres (superusuario)"
echo "  - auth_user"
echo "  - owner_user"
echo "  - pet_user"
echo "  - alert_user"
echo "  - scan_user"

print_info "🔗 URLs de servicios:"
echo "  - Gateway: $GATEWAY_URL"
echo "  - Auth: $AUTH_URL"
echo "  - Owner: $OWNER_URL"
echo "  - Pet: $PET_URL"
echo "  - Alert: $ALERT_URL"
echo "  - AI: $AI_URL"

print_success "✅ Análisis de conexión completado"
print_info "💡 Para conectar los servicios a PostgreSQL, necesitas:"
echo "  1. Actualizar las variables de entorno de cada servicio"
echo "  2. Reconstruir y redeployar los servicios"
echo "  3. Usar las credenciales específicas de cada servicio" 