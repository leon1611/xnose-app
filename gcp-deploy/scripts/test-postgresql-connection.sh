#!/bin/bash

# Script para probar la conexión a PostgreSQL de manera detallada

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

print_info "🔍 Investigación detallada de conectividad PostgreSQL"
print_info "=================================================="

# Configuración
DB_HOST="34.66.242.149"
DB_PORT="5432"
DB_PASSWORD="petnow2024"

print_info "📋 Configuración de prueba:"
echo "  - Host: $DB_HOST"
echo "  - Puerto: $DB_PORT"
echo "  - Contraseña: $DB_PASSWORD"

# 1. Probar conectividad de red
print_info "1️⃣  Probando conectividad de red..."
if nc -zv $DB_HOST $DB_PORT 2>/dev/null; then
    print_success "✅ Conexión de red exitosa"
else
    print_error "❌ Conexión de red falló"
    exit 1
fi

# 2. Verificar configuración SSL
print_info "2️⃣  Verificando configuración SSL..."
SSL_MODE=$(gcloud sql instances describe petnow-dogs-free --project=app-biometrico-db --format="value(settings.ipConfiguration.sslMode)")
print_info "  - Modo SSL: $SSL_MODE"

# 3. Probar diferentes usuarios
print_info "3️⃣  Probando diferentes usuarios..."

# Lista de usuarios a probar
USERS=("postgres" "auth_user" "owner_user" "pet_user" "alert_user" "scan_user")
DATABASES=("postgres" "auth_service_db" "owner_service_db" "pet_service_db" "alert_service_db" "scan_service_db")

for i in "${!USERS[@]}"; do
    USER="${USERS[$i]}"
    DB="${DATABASES[$i]}"
    
    print_info "  Probando usuario: $USER en base: $DB"
    
    # Probar con psql si está disponible
    if command -v psql &> /dev/null; then
        if PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $USER -d $DB -c "SELECT 1;" 2>/dev/null; then
            print_success "    ✅ Conexión exitosa con $USER"
        else
            print_warning "    ⚠️  Conexión falló con $USER"
        fi
    else
        print_warning "    ⚠️  psql no disponible, saltando prueba"
    fi
done

# 4. Verificar configuración de red
print_info "4️⃣  Verificando configuración de red..."
AUTHORIZED_NETWORKS=$(gcloud sql instances describe petnow-dogs-free --project=app-biometrico-db --format="value(settings.ipConfiguration.authorizedNetworks[].value)")

print_info "  - Redes autorizadas: $AUTHORIZED_NETWORKS"

# 5. Verificar estado de la instancia
print_info "5️⃣  Verificando estado de la instancia..."
INSTANCE_STATE=$(gcloud sql instances describe petnow-dogs-free --project=app-biometrico-db --format="value(state)")
print_info "  - Estado: $INSTANCE_STATE"

# 6. Verificar bases de datos
print_info "6️⃣  Verificando bases de datos..."
gcloud sql databases list --instance=petnow-dogs-free --project=app-biometrico-db --format="table(name,charset)"

# 7. Verificar usuarios
print_info "7️⃣  Verificando usuarios..."
gcloud sql users list --instance=petnow-dogs-free --project=app-biometrico-db --format="table(name,host,type)"

# 8. Probar desde Cloud Run (simulación)
print_info "8️⃣  Simulando conexión desde Cloud Run..."
print_info "  - IPs de Cloud Run: Variables (no fijas)"
print_info "  - Problema potencial: Cloud Run no puede acceder directamente"

# 9. Recomendaciones
print_info "9️⃣  Análisis y recomendaciones..."
echo ""
echo "  🔍 PROBLEMAS IDENTIFICADOS:"
echo "    1. Usuarios BUILT_IN pueden no tener contraseñas configuradas"
echo "    2. Cloud Run tiene IPs variables, no fijas"
echo "    3. Configuración SSL puede ser muy restrictiva"
echo ""
echo "  💡 SOLUCIONES POSIBLES:"
echo "    1. Configurar contraseñas para usuarios BUILT_IN"
echo "    2. Usar Cloud SQL Auth Proxy"
echo "    3. Simplificar configuración SSL"
echo "    4. Usar IP pública con SSL flexible"
echo "    5. Mantener H2 para desarrollo/APK"

print_success "✅ Investigación completada" 