#!/bin/bash

# 🚀 X-NOSE - Limpieza de Recursos de Google Cloud
# ⚠️  ADVERTENCIA: Este script elimina TODOS los recursos de X-NOSE
# Solo usar en caso de emergencia o para limpiar completamente

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

# Función para confirmar limpieza
confirm_cleanup() {
    echo ""
    print_error "⚠️  ADVERTENCIA: LIMPIEZA COMPLETA DE RECURSOS"
    echo ""
    echo "Este script eliminará TODOS los recursos de X-NOSE en Google Cloud:"
    echo ""
    echo "🗑️  Servicios a eliminar:"
    echo "   - xnose-gateway-service"
    echo "   - xnose-auth-service"
    echo "   - xnose-owner-service"
    echo "   - xnose-pet-service"
    echo "   - xnose-alert-service"
    echo "   - xnose-ai-service"
    echo ""
    echo "🗑️  Imágenes a eliminar:"
    echo "   - Todas las imágenes Docker en Container Registry"
    echo ""
    echo "🗑️  Otros recursos:"
    echo "   - Buckets de Cloud Storage (si existen)"
    echo ""
    echo "⚠️  Esta acción NO se puede deshacer"
    echo ""
    
    read -p "¿Estás SEGURO de que quieres continuar? (escribe 'ELIMINAR' para confirmar): " confirmation
    
    if [ "$confirmation" != "ELIMINAR" ]; then
        print_message "Limpieza cancelada"
        exit 0
    fi
    
    print_warning "Limpieza confirmada - procediendo..."
}

# Cargar configuración
load_config() {
    if [ ! -f "../configs/gcp-config.env" ]; then
        print_error "Archivo de configuración no encontrado"
        exit 1
    fi
    
    source ../configs/gcp-config.env
    print_success "Configuración cargada"
}

# Eliminar servicios de Cloud Run
delete_cloud_run_services() {
    print_message "Eliminando servicios de Cloud Run..."
    
    services=("gateway-service" "auth-service" "owner-service" "pet-service" "alert-service" "ai-service")
    
    for service in "${services[@]}"; do
        print_message "Eliminando xnose-$service..."
        
        if gcloud run services describe xnose-$service --region=$REGION &> /dev/null; then
            gcloud run services delete xnose-$service --region=$REGION --quiet
            print_success "Servicio eliminado: xnose-$service"
        else
            print_warning "Servicio no encontrado: xnose-$service"
        fi
    done
}

# Eliminar imágenes de Container Registry
delete_container_images() {
    print_message "Eliminando imágenes de Container Registry..."
    
    PROJECT_ID=$(gcloud config get-value project)
    REGISTRY_URL="gcr.io/$PROJECT_ID"
    
    services=("gateway-service" "auth-service" "owner-service" "pet-service" "alert-service" "ai-service")
    
    for service in "${services[@]}"; do
        local image_tag="$REGISTRY_URL/$service:latest"
        
        print_message "Eliminando imagen: $image_tag"
        
        if gcloud container images describe $image_tag &> /dev/null; then
            gcloud container images delete $image_tag --quiet
            print_success "Imagen eliminada: $image_tag"
        else
            print_warning "Imagen no encontrada: $image_tag"
        fi
    done
}

# Eliminar buckets de Cloud Storage
delete_storage_buckets() {
    print_message "Eliminando buckets de Cloud Storage..."
    
    PROJECT_ID=$(gcloud config get-value project)
    BUCKET_NAME="petnow-dogs-images-$PROJECT_ID"
    
    print_message "Eliminando bucket: $BUCKET_NAME"
    
    if gsutil ls -b gs://$BUCKET_NAME &> /dev/null; then
        gsutil -m rm -r gs://$BUCKET_NAME
        print_success "Bucket eliminado: $BUCKET_NAME"
    else
        print_warning "Bucket no encontrado: $BUCKET_NAME"
    fi
}

# Limpiar archivos de configuración
cleanup_config_files() {
    print_message "Limpiando archivos de configuración..."
    
    # Hacer backup del archivo de configuración
    if [ -f "../configs/gcp-config.env" ]; then
        cp ../configs/gcp-config.env ../configs/gcp-config.env.backup
        print_message "Backup creado: configs/gcp-config.env.backup"
    fi
    
    # Limpiar URLs en el archivo de configuración
    if [ -f "../configs/gcp-config.env" ]; then
        sed -i.bak 's/^GATEWAY_URL=.*/GATEWAY_URL=/' ../configs/gcp-config.env
        sed -i.bak 's/^AUTH_URL=.*/AUTH_URL=/' ../configs/gcp-config.env
        sed -i.bak 's/^OWNER_URL=.*/OWNER_URL=/' ../configs/gcp-config.env
        sed -i.bak 's/^PET_URL=.*/PET_URL=/' ../configs/gcp-config.env
        sed -i.bak 's/^ALERT_URL=.*/ALERT_URL=/' ../configs/gcp-config.env
        sed -i.bak 's/^AI_URL=.*/AI_URL=/' ../configs/gcp-config.env
        
        print_success "Archivo de configuración limpiado"
    fi
}

# Mostrar resumen de limpieza
show_cleanup_summary() {
    echo ""
    echo "🧹 RESUMEN DE LIMPIEZA"
    echo "======================"
    echo ""
    echo "✅ Servicios de Cloud Run eliminados"
    echo "✅ Imágenes de Container Registry eliminadas"
    echo "✅ Buckets de Cloud Storage eliminados"
    echo "✅ Archivos de configuración limpiados"
    echo ""
    echo "📁 Backup de configuración: configs/gcp-config.env.backup"
    echo ""
    print_success "¡Limpieza completada exitosamente!"
}

# Función principal
main() {
    echo "🧹 X-NOSE - Limpieza de Recursos de Google Cloud"
    echo "================================================"
    echo ""
    
    confirm_cleanup
    load_config
    delete_cloud_run_services
    delete_container_images
    delete_storage_buckets
    cleanup_config_files
    show_cleanup_summary
    
    echo ""
    print_warning "Para volver a desplegar, ejecuta: ./scripts/deploy-complete.sh"
    echo ""
}

# Ejecutar función principal
main "$@" 