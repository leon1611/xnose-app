#!/bin/bash

echo "🚀 INICIALIZANDO REPOSITORIO DE DESPLIEGUE X-NOSE"
echo "================================================"
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

# Función para inicializar Git
init_git() {
    print_status "Inicializando repositorio Git..."
    
    if [ -d ".git" ]; then
        print_warning "Repositorio Git ya existe"
    else
        git init
        print_success "Repositorio Git inicializado"
    fi
    
    echo ""
}

# Función para crear README
create_readme() {
    print_status "Verificando README..."
    
    if [ ! -f "README.md" ]; then
        print_error "README.md no encontrado"
        exit 1
    else
        print_success "README.md encontrado"
    fi
    
    echo ""
}

# Función para verificar estructura
check_structure() {
    print_status "Verificando estructura de archivos..."
    
    required_files=(
        "render.yaml"
        "dockerfiles/gateway-service/Dockerfile"
        "dockerfiles/auth-service/Dockerfile"
        "dockerfiles/owner-service/Dockerfile"
        "dockerfiles/pet-service/Dockerfile"
        "dockerfiles/alert-service/Dockerfile"
        "dockerfiles/ai-service/Dockerfile"
        "dockerfiles/frontend/Dockerfile"
        "configs/gateway-service/application-prod.yml"
        "configs/auth-service/application-prod.yml"
        "configs/owner-service/application-prod.yml"
        "configs/pet-service/application-prod.yml"
        "configs/alert-service/application-prod.yml"
        "configs/frontend/app.config.prod.js"
        "configs/ai-service/config.py"
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

# Función para hacer commit inicial
make_initial_commit() {
    print_status "Haciendo commit inicial..."
    
    git add .
    git commit -m "Initial commit: X-NOSE deployment configuration"
    
    print_success "Commit inicial realizado"
    echo ""
}

# Función para mostrar instrucciones
show_instructions() {
    print_status "INSTRUCCIONES PARA SUBIR A GITHUB"
    echo "======================================"
    echo ""
    
    echo "1. Crea un nuevo repositorio en GitHub:"
    echo "   - Ve a https://github.com/new"
    echo "   - Nombre: xnose-deploy (o el que prefieras)"
    echo "   - Descripción: X-NOSE deployment configuration"
    echo "   - NO inicialices con README (ya existe)"
    echo ""
    
    echo "2. Conecta tu repositorio local:"
    echo "   git remote add origin https://github.com/TU_USUARIO/xnose-deploy.git"
    echo "   git branch -M main"
    echo "   git push -u origin main"
    echo ""
    
    echo "3. Configura Render:"
    echo "   - Ve a https://dashboard.render.com/"
    echo "   - Crea un nuevo 'Blueprint'"
    echo "   - Conecta tu repositorio de GitHub"
    echo "   - Render detectará automáticamente el render.yaml"
    echo ""
    
    echo "4. Configura las variables de entorno en Render:"
    echo "   - Base de datos PostgreSQL"
    echo "   - Google Cloud Storage"
    echo "   - URLs de servicios"
    echo ""
}

# Función para mostrar estructura
show_structure() {
    print_status "ESTRUCTURA DEL REPOSITORIO"
    echo "============================="
    echo ""
    
    echo "deploy-only/"
    echo "├── README.md"
    echo "├── render.yaml"
    echo "├── .gitignore"
    echo "├── dockerfiles/"
    echo "│   ├── gateway-service/"
    echo "│   ├── auth-service/"
    echo "│   ├── owner-service/"
    echo "│   ├── pet-service/"
    echo "│   ├── alert-service/"
    echo "│   ├── ai-service/"
    echo "│   └── frontend/"
    echo "├── configs/"
    echo "│   ├── gateway-service/"
    echo "│   ├── auth-service/"
    echo "│   ├── owner-service/"
    echo "│   ├── pet-service/"
    echo "│   ├── alert-service/"
    echo "│   ├── ai-service/"
    echo "│   └── frontend/"
    echo "└── scripts/"
    echo "    └── deploy-render.sh"
    echo ""
}

# Función principal
main() {
    echo "🚀 INICIANDO CONFIGURACIÓN DE REPOSITORIO DE DESPLIEGUE"
    echo "====================================================="
    echo ""
    
    check_structure
    create_readme
    init_git
    make_initial_commit
    
    echo ""
    show_structure
    echo ""
    show_instructions
    
    print_success "¡Repositorio de despliegue listo!"
    print_status "Ahora puedes subirlo a GitHub y conectar con Render."
}

# Ejecutar función principal
main 