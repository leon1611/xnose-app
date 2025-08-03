#!/bin/bash

# 🚀 X-NOSE - Monitorear Servicios en Google Cloud Run
# Este script monitorea el estado de todos los servicios desplegados

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
    if [ ! -f "configs/gcp-config.env" ]; then
        print_error "Archivo de configuración no encontrado. Ejecuta primero: ./scripts/setup-gcp.sh"
        exit 1
    fi
    
    source configs/gcp-config.env
    print_success "Configuración cargada"
}

# Verificar estado de un servicio
check_service_status() {
    local service_name=$1
    local service_url=$2
    
    print_message "Verificando $service_name..."
    
    # Verificar si el servicio está ejecutándose
    local status=$(gcloud run services describe xnose-$service_name --region=$REGION --format="value(status.conditions[0].status)" 2>/dev/null || echo "NOT_FOUND")
    
    if [ "$status" = "True" ]; then
        print_success "$service_name está ejecutándose"
        
        # Probar endpoint de health
        if [ ! -z "$service_url" ]; then
            local health_endpoint=""
            
            case $service_name in
                "gateway-service"|"auth-service"|"owner-service"|"pet-service"|"alert-service")
                    health_endpoint="$service_url/actuator/health"
                    ;;
                "ai-service")
                    health_endpoint="$service_url/health"
                    ;;
            esac
            
            if [ ! -z "$health_endpoint" ]; then
                local response=$(curl -s -o /dev/null -w "%{http_code}" $health_endpoint 2>/dev/null || echo "000")
                
                if [ "$response" = "200" ]; then
                    print_success "$service_name health check: OK"
                else
                    print_warning "$service_name health check: HTTP $response"
                fi
            fi
        fi
        
    elif [ "$status" = "False" ]; then
        print_error "$service_name no está ejecutándose correctamente"
    else
        print_error "$service_name no encontrado"
    fi
    
    echo ""
}

# Mostrar información detallada de servicios
show_service_details() {
    print_message "Información detallada de servicios..."
    
    echo ""
    echo "=== Detalles de Servicios ==="
    gcloud run services list --region=$REGION --format="table(metadata.name,status.url,status.conditions[0].status,status.conditions[0].message)"
    echo ""
}

# Mostrar logs recientes
show_recent_logs() {
    local service_name=$1
    
    print_message "Mostrando logs recientes de $service_name..."
    
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=xnose-$service_name" \
        --limit=10 \
        --format="table(timestamp,severity,textPayload)" \
        --project=$(gcloud config get-value project)
    
    echo ""
}

# Mostrar métricas de uso
show_usage_metrics() {
    print_message "Métricas de uso de servicios..."
    
    echo ""
    echo "=== Métricas de Uso ==="
    
    # Obtener información de instancias
    for service in "gateway-service" "auth-service" "owner-service" "pet-service" "alert-service" "ai-service"; do
        local instances=$(gcloud run services describe xnose-$service --region=$REGION --format="value(status.observedGeneration)" 2>/dev/null || echo "0")
        echo "$service: $instances instancias"
    done
    
    echo ""
}

# Probar endpoints principales
test_main_endpoints() {
    print_message "Probando endpoints principales..."
    
    if [ ! -z "$GATEWAY_URL" ]; then
        echo ""
        echo "=== Pruebas de Endpoints ==="
        
        # Probar Gateway
        local gateway_response=$(curl -s -o /dev/null -w "%{http_code}" $GATEWAY_URL/actuator/health 2>/dev/null || echo "000")
        echo "Gateway Health: HTTP $gateway_response"
        
        # Probar AI Service
        if [ ! -z "$AI_URL" ]; then
            local ai_response=$(curl -s -o /dev/null -w "%{http_code}" $AI_URL/health 2>/dev/null || echo "000")
            echo "AI Service Health: HTTP $ai_response"
        fi
        
        # Probar Auth Service
        if [ ! -z "$AUTH_URL" ]; then
            local auth_response=$(curl -s -o /dev/null -w "%{http_code}" $AUTH_URL/actuator/health 2>/dev/null || echo "000")
            echo "Auth Service Health: HTTP $auth_response"
        fi
        
        echo ""
    fi
}

# Mostrar costos estimados
show_cost_estimate() {
    print_message "Estimación de costos..."
    
    echo ""
    echo "=== Estimación de Costos ==="
    echo "Cloud Run (6 servicios): ~$30-50/mes"
    echo "Cloud SQL (ya configurado): ~$25-35/mes"
    echo "Cloud Storage: ~$5-10/mes"
    echo "Total estimado: ~$60-95/mes"
    echo ""
}

# Función principal de monitoreo
main_monitoring() {
    echo "📊 Monitoreando Servicios de X-NOSE"
    echo "==================================="
    echo ""
    
    load_config
    
    # Verificar estado de cada servicio
    check_service_status "gateway-service" "$GATEWAY_URL"
    check_service_status "auth-service" "$AUTH_URL"
    check_service_status "owner-service" "$OWNER_URL"
    check_service_status "pet-service" "$PET_URL"
    check_service_status "alert-service" "$ALERT_URL"
    check_service_status "ai-service" "$AI_URL"
    
    show_service_details
    show_usage_metrics
    test_main_endpoints
    show_cost_estimate
    
    print_success "Monitoreo completado"
}

# Función para monitoreo continuo
continuous_monitoring() {
    print_message "Iniciando monitoreo continuo (Ctrl+C para detener)..."
    
    while true; do
        clear
        echo "🔄 Monitoreo Continuo - $(date)"
        echo "=================================="
        echo ""
        
        main_monitoring
        
        echo "Actualizando en 30 segundos..."
        sleep 30
    done
}

# Función para mostrar logs de un servicio específico
show_service_logs() {
    local service_name=$1
    
    if [ -z "$service_name" ]; then
        print_error "Debes especificar un nombre de servicio"
        echo "Uso: $0 logs <service-name>"
        echo "Servicios disponibles: gateway-service, auth-service, owner-service, pet-service, alert-service, ai-service"
        exit 1
    fi
    
    show_recent_logs $service_name
}

# Función principal
main() {
    case "${1:-monitor}" in
        "monitor")
            main_monitoring
            ;;
        "continuous")
            continuous_monitoring
            ;;
        "logs")
            show_service_logs $2
            ;;
        "help"|"-h"|"--help")
            echo "Uso: $0 [comando]"
            echo ""
            echo "Comandos disponibles:"
            echo "  monitor     - Monitoreo básico (por defecto)"
            echo "  continuous  - Monitoreo continuo"
            echo "  logs <service> - Mostrar logs de un servicio específico"
            echo "  help        - Mostrar esta ayuda"
            echo ""
            echo "Ejemplos:"
            echo "  $0 monitor"
            echo "  $0 continuous"
            echo "  $0 logs gateway-service"
            ;;
        *)
            print_error "Comando desconocido: $1"
            echo "Usa '$0 help' para ver comandos disponibles"
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@" 