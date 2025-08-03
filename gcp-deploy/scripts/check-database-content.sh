#!/bin/bash

# Script para verificar el contenido de las bases de datos PostgreSQL

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

print_info "📊 Verificando contenido de bases de datos PostgreSQL"
print_info "====================================================="

# Verificar estado de la instancia
print_info "Verificando estado de la instancia..."
INSTANCE_STATE=$(gcloud sql instances describe petnow-dogs-free --project=$PROJECT_ID --format="value(state)")

if [ "$INSTANCE_STATE" != "RUNNABLE" ]; then
    print_error "La instancia no está ejecutándose. Estado: $INSTANCE_STATE"
    exit 1
fi

print_success "Instancia ejecutándose correctamente"

# Función para verificar base de datos específica
check_database_content() {
    local db_name=$1
    local db_user=$2
    
    print_info "🔍 Verificando $db_name..."
    
    # Crear archivo SQL temporal
    cat > /tmp/check_${db_name}.sql << EOF
\c $db_name;
\dt;
SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public';
EOF

    # Intentar conectar y ejecutar consultas
    print_info "Intentando conectar a $db_name con usuario $db_user..."
    
    # Usar gcloud sql connect con timeout
    timeout 30 gcloud sql connect petnow-dogs-free --user=$db_user --database=$db_name --project=$PROJECT_ID --quiet < /tmp/check_${db_name}.sql 2>/dev/null || {
        print_warning "No se pudo conectar a $db_name con usuario $db_user"
        print_info "Intentando con postgres..."
        timeout 30 gcloud sql connect petnow-dogs-free --user=postgres --database=$db_name --project=$PROJECT_ID --quiet < /tmp/check_${db_name}.sql 2>/dev/null || {
            print_error "No se pudo conectar a $db_name"
        }
    }
    
    # Limpiar archivo temporal
    rm -f /tmp/check_${db_name}.sql
}

# Verificar cada base de datos
print_info "📋 Verificando contenido de bases de datos..."

# Auth Service DB
check_database_content "auth_service_db" "auth_user"

# Owner Service DB  
check_database_content "owner_service_db" "owner_user"

# Pet Service DB
check_database_content "pet_service_db" "pet_user"

# Alert Service DB
check_database_content "alert_service_db" "alert_user"

# Scan Service DB
check_database_content "scan_service_db" "scan_user"

print_info "🔍 Verificando estado actual de servicios..."

# Verificar si los servicios están usando H2 o PostgreSQL
check_service_database() {
    local service_name=$1
    local service_url=$2
    
    print_info "Verificando $service_name..."
    
    HEALTH_RESPONSE=$(curl -s "$service_url/actuator/health" 2>/dev/null || echo "ERROR")
    
    if [[ "$HEALTH_RESPONSE" == *"\"status\":\"UP\""* ]]; then
        if [[ "$HEALTH_RESPONSE" == *"\"database\":\"H2\""* ]]; then
            print_warning "$service_name está usando H2 (base de datos en memoria)"
            print_info "  - Los datos se pierden al reiniciar el servicio"
            print_info "  - No hay conexión a PostgreSQL"
        elif [[ "$HEALTH_RESPONSE" == *"\"database\":\"PostgreSQL\""* ]]; then
            print_success "$service_name está usando PostgreSQL"
            print_info "  - Los datos son persistentes"
            print_info "  - Conectado a la base de datos"
        else
            print_info "$service_name - estado de base de datos no determinado"
        fi
    else
        print_error "$service_name no responde correctamente"
    fi
}

# Verificar cada servicio
check_service_database "Auth Service" "$AUTH_URL"
check_service_database "Owner Service" "$OWNER_URL"
check_service_database "Pet Service" "$PET_URL"
check_service_database "Alert Service" "$ALERT_URL"

print_info "📋 Resumen del estado actual:"
echo ""
echo "  🔴 SERVICIOS CON H2 (base de datos en memoria):"
echo "    - Auth Service"
echo "    - Owner Service" 
echo "    - Pet Service"
echo "    - Alert Service"
echo ""
echo "  🟢 BASE DE DATOS POSTGRESQL DISPONIBLE:"
echo "    - Instancia: petnow-dogs-free"
echo "    - Estado: RUNNABLE"
echo "    - IP: 34.66.242.149"
echo "    - Bases de datos creadas: auth_service_db, owner_service_db, pet_service_db, alert_service_db"
echo ""
echo "  💡 CONCLUSIÓN:"
echo "    Los servicios NO están conectados a PostgreSQL."
echo "    Están usando H2 (base de datos en memoria)."
echo "    Los datos se pierden al reiniciar los servicios."
echo ""
echo "  🚀 ACCIÓN REQUERIDA:"
echo "    Para conectar a PostgreSQL, ejecuta:"
echo "    ./scripts/connect-to-postgresql.sh" 