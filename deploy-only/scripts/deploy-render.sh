#!/bin/bash

echo "🚀 DESPLIEGUE EN RENDER - X-NOSE"
echo "====================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
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

# Función para verificar prerequisitos
check_prerequisites() {
    print_status "Verificando prerequisitos..."
    
    # Verificar Git
    if ! command -v git &> /dev/null; then
        print_error "Git no está instalado"
        exit 1
    fi
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        print_warning "Docker no está instalado (necesario para pruebas locales)"
    fi
    
    # Verificar que estamos en el directorio correcto
    if [ ! -f "render.yaml" ]; then
        print_error "No se encontró render.yaml. Ejecuta este script desde la raíz del proyecto."
        exit 1
    fi
    
    print_success "Prerequisitos verificados"
    echo ""
}

# Función para verificar archivos necesarios
check_required_files() {
    print_status "Verificando archivos necesarios..."
    
    required_files=(
        "render.yaml"
        "gateway-service/Dockerfile"
        "auth-service/Dockerfile"
        "owner-service/Dockerfile"
        "pet-service/Dockerfile"
        "alert-service/Dockerfile"
        "ai-service/Dockerfile"
        "frontend/Dockerfile"
        "gateway-service/.dockerignore"
        "auth-service/.dockerignore"
        "owner-service/.dockerignore"
        "pet-service/.dockerignore"
        "alert-service/.dockerignore"
        "ai-service/.dockerignore"
        "frontend/.dockerignore"
    )
    
    missing_files=()
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        print_error "Faltan los siguientes archivos:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        exit 1
    fi
    
    print_success "Todos los archivos necesarios están presentes"
    echo ""
}

# Función para verificar configuración de Git
check_git_status() {
    print_status "Verificando estado de Git..."
    
    # Verificar que estamos en un repositorio Git
    if [ ! -d ".git" ]; then
        print_error "No se encontró un repositorio Git. Inicializa Git primero:"
        echo "  git init"
        echo "  git remote add origin <tu-repositorio-github>"
        exit 1
    fi
    
    # Verificar que hay cambios para commitear
    if [ -z "$(git status --porcelain)" ]; then
        print_warning "No hay cambios para commitear"
    else
        print_status "Hay cambios sin commitear. ¿Deseas commitearlos? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "Add Docker configuration for Render deployment"
            print_success "Cambios commiteados"
        fi
    fi
    
    # Verificar que hay un remote configurado
    if ! git remote get-url origin &> /dev/null; then
        print_error "No hay un remote 'origin' configurado. Configura tu repositorio GitHub:"
        echo "  git remote add origin <tu-repositorio-github>"
        exit 1
    fi
    
    print_success "Estado de Git verificado"
    echo ""
}

# Función para mostrar instrucciones de configuración
show_configuration_instructions() {
    print_status "INSTRUCCIONES DE CONFIGURACIÓN"
    echo "=================================="
    echo ""
    
    echo "1. Ve a https://dashboard.render.com/"
    echo "2. Crea un nuevo 'Blueprint'"
    echo "3. Conecta tu repositorio de GitHub"
    echo "4. Render detectará automáticamente el render.yaml"
    echo ""
    
    echo "VARIABLES DE ENTORNO NECESARIAS:"
    echo "================================"
    echo ""
    
    echo "Gateway Service:"
    echo "  SPRING_PROFILES_ACTIVE=production"
    echo "  SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/pet_service_db"
    echo "  SPRING_DATASOURCE_USERNAME=pet_user"
    echo "  SPRING_DATASOURCE_PASSWORD=leon1611"
    echo "  AUTH_SERVICE_URL=https://xnose-auth-service.onrender.com"
    echo "  OWNER_SERVICE_URL=https://xnose-owner-service.onrender.com"
    echo "  PET_SERVICE_URL=https://xnose-pet-service.onrender.com"
    echo "  ALERT_SERVICE_URL=https://xnose-alert-service.onrender.com"
    echo "  AI_SERVICE_URL=https://xnose-ai-service.onrender.com"
    echo ""
    
    echo "Auth Service:"
    echo "  SPRING_PROFILES_ACTIVE=production"
    echo "  SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/auth_service_db"
    echo "  SPRING_DATASOURCE_USERNAME=auth_user"
    echo "  SPRING_DATASOURCE_PASSWORD=leon1611"
    echo ""
    
    echo "Owner Service:"
    echo "  SPRING_PROFILES_ACTIVE=production"
    echo "  SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/owner_service_db"
    echo "  SPRING_DATASOURCE_USERNAME=owner_user"
    echo "  SPRING_DATASOURCE_PASSWORD=leon1611"
    echo ""
    
    echo "Pet Service:"
    echo "  SPRING_PROFILES_ACTIVE=production"
    echo "  SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/pet_service_db"
    echo "  SPRING_DATASOURCE_USERNAME=pet_user"
    echo "  SPRING_DATASOURCE_PASSWORD=leon1611"
    echo "  GCS_BUCKET_NAME=petnow-dogs-images-app-biometrico-db"
    echo "  GOOGLE_CLOUD_PROJECT=app-biometrico-db"
    echo "  AI_SERVICE_URL=https://xnose-ai-service.onrender.com"
    echo ""
    
    echo "Alert Service:"
    echo "  SPRING_PROFILES_ACTIVE=production"
    echo "  SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/alert_service_db"
    echo "  SPRING_DATASOURCE_USERNAME=alert_user"
    echo "  SPRING_DATASOURCE_PASSWORD=leon1611"
    echo ""
    
    echo "AI Service:"
    echo "  PYTHONUNBUFFERED=1"
    echo "  LOG_LEVEL=INFO"
    echo "  SIMILARITY_THRESHOLD=0.80"
    echo "  CONFIDENCE_BOOST=0.1"
    echo ""
    
    echo "Frontend:"
    echo "  EXPO_PUBLIC_API_URL=https://xnose-gateway.onrender.com"
    echo "  EXPO_PUBLIC_AI_SERVICE_URL=https://xnose-ai-service.onrender.com"
    echo "  EXPO_PUBLIC_GCS_BUCKET_URL=https://storage.googleapis.com/petnow-dogs-images-app-biometrico-db"
    echo ""
}

# Función para mostrar URLs esperadas
show_expected_urls() {
    print_status "URLs ESPERADAS DESPUÉS DEL DESPLIEGUE"
    echo "=========================================="
    echo ""
    
    echo "Gateway: https://xnose-gateway.onrender.com"
    echo "Auth Service: https://xnose-auth-service.onrender.com"
    echo "Owner Service: https://xnose-owner-service.onrender.com"
    echo "Pet Service: https://xnose-pet-service.onrender.com"
    echo "Alert Service: https://xnose-alert-service.onrender.com"
    echo "AI Service: https://xnose-ai-service.onrender.com"
    echo "Frontend: https://xnose-frontend.onrender.com"
    echo ""
}

# Función para mostrar comandos de prueba
show_test_commands() {
    print_status "COMANDOS DE PRUEBA POST-DESPLIEGUE"
    echo "========================================"
    echo ""
    
    echo "# Verificar health checks"
    echo "curl https://xnose-gateway.onrender.com/actuator/health"
    echo "curl https://xnose-auth-service.onrender.com/actuator/health"
    echo "curl https://xnose-owner-service.onrender.com/actuator/health"
    echo "curl https://xnose-pet-service.onrender.com/actuator/health"
    echo "curl https://xnose-alert-service.onrender.com/actuator/health"
    echo "curl https://xnose-ai-service.onrender.com/health"
    echo ""
    
    echo "# Verificar rutas del gateway"
    echo "curl https://xnose-gateway.onrender.com/actuator/gateway/routes"
    echo ""
    
    echo "# Verificar estadísticas del modelo AI"
    echo "curl https://xnose-ai-service.onrender.com/model-stats"
    echo ""
}

# Función principal
main() {
    echo "🚀 INICIANDO PROCESO DE DESPLIEGUE EN RENDER"
    echo "============================================"
    echo ""
    
    check_prerequisites
    check_required_files
    check_git_status
    
    print_status "¿Deseas hacer push al repositorio? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git push origin main
        print_success "Código subido a GitHub"
    fi
    
    echo ""
    show_configuration_instructions
    echo ""
    show_expected_urls
    echo ""
    show_test_commands
    
    print_success "¡Proceso de preparación completado!"
    print_status "Ahora sigue las instrucciones para configurar Render."
}

# Ejecutar función principal
main 