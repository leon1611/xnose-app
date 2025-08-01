#!/bin/bash

echo "🎯 VERIFICACIÓN FINAL DE MEJORAS DEL AI SERVICE"
echo "==============================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Función para verificar servicio
check_service() {
    local service_name=$1
    local url=$2
    local endpoint=$3
    
    if curl -s "$url$endpoint" > /dev/null; then
        print_status "OK" "$service_name: Funcionando"
        return 0
    else
        print_status "ERROR" "$service_name: No responde"
        return 1
    fi
}

# Función para verificar AI Service específicamente
check_ai_service() {
    echo ""
    print_status "INFO" "Verificando AI Service..."
    
    if ! check_service "AI Service" "http://localhost:8000" "/health"; then
        return 1
    fi
    
    # Obtener detalles del health check
    HEALTH_RESPONSE=$(curl -s http://localhost:8000/health)
    
    # Verificar modelos
    MODELS=$(echo $HEALTH_RESPONSE | python3 -c "import sys, json; print(', '.join(json.load(sys.stdin)['available_models']))")
    print_status "OK" "Modelos disponibles: $MODELS"
    
    # Verificar configuración
    THRESHOLD=$(echo $HEALTH_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['threshold'])")
    BOOST=$(echo $HEALTH_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['confidence_boost'])")
    PETS=$(echo $HEALTH_RESPONSE | python3 -c "import sys, json; print(json.load(sys.stdin)['total_pets_advanced'])")
    
    print_status "OK" "Umbral: $THRESHOLD"
    print_status "OK" "Confidence Boost: $BOOST"
    print_status "OK" "Mascotas registradas: $PETS"
    
    return 0
}

# Función para probar funcionalidad básica
test_basic_functionality() {
    echo ""
    print_status "INFO" "Probando funcionalidad básica..."
    
    # Verificar que hay imágenes de prueba
    if [ -f "ai-service/husky_nose.jpg" ] && [ -f "ai-service/husky_profile.jpg" ]; then
        print_status "OK" "Imágenes de prueba disponibles"
    else
        print_status "WARN" "No se encontraron imágenes de prueba"
        return 0
    fi
    
    # Probar registro de mascota usando Python
    cd ai-service
    source venv/bin/activate
    
    PET_ID="verify-test-$(date +%s)"
    
    # Crear script temporal de Python
    cat > temp_test.py << EOF
import requests
import sys

try:
    # Registrar mascota
    with open('husky_nose.jpg', 'rb') as f:
        files = {'image': ('husky_nose.jpg', f, 'image/jpeg')}
        params = {'petId': '$PET_ID'}
        response = requests.post('http://localhost:8000/register-embedding', files=files, params=params)
        if response.status_code == 200:
            print("OK: Registro de mascota exitoso")
        else:
            print("ERROR: Error en registro de mascota")
            sys.exit(1)
    
    # Probar comparación
    with open('husky_nose.jpg', 'rb') as f:
        files = {'image': ('husky_nose.jpg', f, 'image/jpeg')}
        response = requests.post('http://localhost:8000/compare', files=files)
        if response.status_code == 200:
            result = response.json()
            if result['match']:
                print("OK: Comparación exitosa - Coincidencia detectada")
                print("OK: Confianza: " + str(result['confidence']))
            else:
                print("WARN: Comparación exitosa - Sin coincidencia")
        else:
            print("ERROR: Error en comparación")
            sys.exit(1)
            
except Exception as e:
    print("ERROR: " + str(e))
    sys.exit(1)
EOF
    
    # Ejecutar script de Python
    python temp_test.py
    TEST_RESULT=$?
    
    # Limpiar archivo temporal
    rm temp_test.py
    
    cd ..
    
    if [ $TEST_RESULT -eq 0 ]; then
        print_status "OK" "Pruebas de funcionalidad exitosas"
        return 0
    else
        print_status "ERROR" "Pruebas de funcionalidad fallaron"
        return 1
    fi
}

# Función para verificar archivos importantes
check_important_files() {
    echo ""
    print_status "INFO" "Verificando archivos importantes..."
    
    IMPORTANT_FILES=(
        "ai-service/advanced_nose_model.py"
        "ai-service/main.py"
        "ai-service/test_advanced_model.py"
        "scripts/restart-ai-service.sh"
        "scripts/test-ai-from-frontend.sh"
        "MEJORAS_AI_SERVICE.md"
    )
    
    for file in "${IMPORTANT_FILES[@]}"; do
        if [ -f "$file" ]; then
            print_status "OK" "Archivo encontrado: $file"
        else
            print_status "ERROR" "Archivo faltante: $file"
        fi
    done
}

# Función para mostrar resumen
show_summary() {
    echo ""
    echo "📊 RESUMEN DE VERIFICACIÓN"
    echo "=========================="
    
    # Contar servicios funcionando
    SERVICES_RUNNING=0
    TOTAL_SERVICES=3
    
    if check_service "Gateway" "http://localhost:8080" "/actuator/health" > /dev/null; then
        ((SERVICES_RUNNING++))
    fi
    
    if check_service "Pet Service" "http://localhost:8083" "/actuator/health" > /dev/null; then
        ((SERVICES_RUNNING++))
    fi
    
    if check_service "AI Service" "http://localhost:8000" "/health" > /dev/null; then
        ((SERVICES_RUNNING++))
    fi
    
    print_status "INFO" "Servicios funcionando: $SERVICES_RUNNING/$TOTAL_SERVICES"
    
    if [ $SERVICES_RUNNING -eq $TOTAL_SERVICES ]; then
        print_status "OK" "Todos los servicios están funcionando"
    else
        print_status "WARN" "Algunos servicios no están funcionando"
    fi
    
    # Verificar configuración del AI Service
    AI_HEALTH=$(curl -s http://localhost:8000/health 2>/dev/null)
    if [ ! -z "$AI_HEALTH" ]; then
        THRESHOLD=$(echo $AI_HEALTH | python3 -c "import sys, json; print(json.load(sys.stdin)['threshold'])" 2>/dev/null)
        BOOST=$(echo $AI_HEALTH | python3 -c "import sys, json; print(json.load(sys.stdin)['confidence_boost'])" 2>/dev/null)
        PETS=$(echo $AI_HEALTH | python3 -c "import sys, json; print(json.load(sys.stdin)['total_pets_advanced'])" 2>/dev/null)
        
        print_status "INFO" "AI Service configurado:"
        print_status "INFO" "  - Umbral: $THRESHOLD"
        print_status "INFO" "  - Confidence Boost: $BOOST"
        print_status "INFO" "  - Mascotas registradas: $PETS"
    fi
}

# Función para mostrar instrucciones finales
show_final_instructions() {
    echo ""
    echo "🎉 VERIFICACIÓN COMPLETADA"
    echo "=========================="
    echo ""
    echo "📱 Para probar desde el móvil:"
    echo "   1. cd frontend && npm start"
    echo "   2. Escanear QR con Expo Go"
    echo "   3. Registrar mascota con foto de nariz"
    echo "   4. Probar escáner con la misma mascota"
    echo ""
    echo "🛠️ Comandos útiles:"
    echo "   - Reiniciar AI: ./scripts/restart-ai-service.sh"
    echo "   - Probar modelo: cd ai-service && python test_advanced_model.py"
    echo "   - Monitorear: tail -f ai-service/ai_service.log"
    echo ""
    echo "📋 Documentación:"
    echo "   - MEJORAS_AI_SERVICE.md: Detalles completos"
    echo "   - CONFIGURACION_FUNCIONAL.md: Estado general del sistema"
    echo ""
}

# Función principal
main() {
    echo "🕐 $(date)"
    echo ""
    
    # Verificar servicios básicos
    print_status "INFO" "Verificando servicios..."
    check_service "Gateway" "http://localhost:8080" "/actuator/health"
    check_service "Pet Service" "http://localhost:8083" "/actuator/health"
    
    # Verificar AI Service en detalle
    if ! check_ai_service; then
        print_status "ERROR" "AI Service no está funcionando correctamente"
        exit 1
    fi
    
    # Verificar archivos importantes
    check_important_files
    
    # Probar funcionalidad básica
    test_basic_functionality
    
    # Mostrar resumen
    show_summary
    
    # Mostrar instrucciones finales
    show_final_instructions
    
    print_status "OK" "Verificación completada exitosamente"
}

# Ejecutar función principal
main 