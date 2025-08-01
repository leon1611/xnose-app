#!/bin/bash

echo "🧪 PROBANDO AI SERVICE DESDE EL FRONTEND"
echo "========================================"

# Función para verificar servicios
check_services() {
    echo "🔍 Verificando servicios..."
    
    # Verificar AI Service
    if curl -s http://localhost:8000/health > /dev/null; then
        echo "✅ AI Service: OK"
        AI_HEALTH=$(curl -s http://localhost:8000/health)
        echo "   - Mascotas registradas: $(echo $AI_HEALTH | python3 -c "import sys, json; print(json.load(sys.stdin)['total_pets_advanced'])")"
        echo "   - Umbral: $(echo $AI_HEALTH | python3 -c "import sys, json; print(json.load(sys.stdin)['threshold'])")"
    else
        echo "❌ AI Service: NO RESPONDE"
        return 1
    fi
    
    # Verificar Gateway
    if curl -s http://localhost:8080/actuator/health > /dev/null; then
        echo "✅ Gateway Service: OK"
    else
        echo "❌ Gateway Service: NO RESPONDE"
        return 1
    fi
    
    # Verificar Pet Service
    if curl -s http://localhost:8083/actuator/health > /dev/null; then
        echo "✅ Pet Service: OK"
    else
        echo "❌ Pet Service: NO RESPONDE"
        return 1
    fi
    
    return 0
}

# Función para mostrar instrucciones de prueba
show_test_instructions() {
    echo ""
    echo "📱 INSTRUCCIONES PARA PROBAR DESDE EL FRONTEND"
    echo "=============================================="
    echo ""
    echo "1. 🚀 Iniciar el frontend:"
    echo "   cd frontend && npm start"
    echo ""
    echo "2. 📱 Abrir en tu móvil:"
    echo "   - Escanear el código QR"
    echo "   - O usar: expo://192.168.0.104:19000"
    echo ""
    echo "3. 🔐 Iniciar sesión o registrar usuario"
    echo ""
    echo "4. 🐕 Registrar una nueva mascota:"
    echo "   - Ir a 'Mascotas'"
    echo "   - Tocar '+' para agregar"
    echo "   - Llenar datos básicos"
    echo "   - Subir foto de perfil"
    echo "   - Subir foto de nariz (IMPORTANTE)"
    echo "   - Guardar"
    echo ""
    echo "5. 🔍 Probar escáner:"
    echo "   - Ir a 'Escáner'"
    echo "   - Tomar foto de nariz de la misma mascota"
    echo "   - Verificar que detecte la coincidencia"
    echo ""
    echo "6. 🧪 Probar con diferentes condiciones:"
    echo "   - Diferentes ángulos de la nariz"
    echo "   - Diferente iluminación"
    echo "   - Diferente distancia"
    echo ""
    echo "7. 📊 Verificar resultados:"
    echo "   - Debe mostrar nombre de la mascota"
    echo "   - Debe mostrar confianza alta (>80%)"
    echo "   - Debe funcionar con la misma mascota"
    echo ""
}

# Función para probar endpoints directamente
test_endpoints() {
    echo ""
    echo "🔗 PROBANDO ENDPOINTS DIRECTAMENTE"
    echo "================================="
    
    # Probar health del AI Service
    echo "📊 AI Service Health:"
    curl -s http://localhost:8000/health | python3 -m json.tool
    
    # Probar estadísticas del modelo
    echo ""
    echo "📈 Modelo Stats:"
    curl -s http://localhost:8000/model-stats | python3 -m json.tool
    
    # Probar gateway health
    echo ""
    echo "🌐 Gateway Health:"
    curl -s http://localhost:8080/actuator/health | python3 -m json.tool
}

# Función para mostrar configuración actual
show_configuration() {
    echo ""
    echo "⚙️ CONFIGURACIÓN ACTUAL"
    echo "======================="
    
    # Obtener configuración del AI Service
    AI_CONFIG=$(curl -s http://localhost:8000/health)
    
    echo "🤖 AI Service:"
    echo "   - Puerto: 8000"
    echo "   - Umbral: $(echo $AI_CONFIG | python3 -c "import sys, json; print(json.load(sys.stdin)['threshold'])")"
    echo "   - Confidence Boost: $(echo $AI_CONFIG | python3 -c "import sys, json; print(json.load(sys.stdin)['confidence_boost'])")"
    echo "   - Modelos: $(echo $AI_CONFIG | python3 -c "import sys, json; print(', '.join(json.load(sys.stdin)['available_models']))")"
    echo "   - Mascotas registradas: $(echo $AI_CONFIG | python3 -c "import sys, json; print(json.load(sys.stdin)['total_pets_advanced'])")"
    
    echo ""
    echo "🌐 Gateway:"
    echo "   - Puerto: 8080"
    echo "   - Estado: $(curl -s http://localhost:8080/actuator/health | python3 -c "import sys, json; print(json.load(sys.stdin)['status'])")"
    
    echo ""
    echo "🐕 Pet Service:"
    echo "   - Puerto: 8083"
    echo "   - Estado: $(curl -s http://localhost:8083/actuator/health | python3 -c "import sys, json; print(json.load(sys.stdin)['status'])")"
    
    echo ""
    echo "📱 Frontend:"
    echo "   - Puerto: 19000"
    echo "   - IP: 192.168.0.104"
    echo "   - URL: expo://192.168.0.104:19000"
}

# Función para mostrar logs en tiempo real
show_logs() {
    echo ""
    echo "📋 MONITOREO DE LOGS"
    echo "==================="
    echo "Presiona Ctrl+C para salir del monitoreo"
    echo ""
    
    # Mostrar logs del AI Service
    if [ -f "ai-service/ai_service.log" ]; then
        echo "🤖 AI Service Logs:"
        tail -f ai-service/ai_service.log &
        AI_LOG_PID=$!
    fi
    
    # Mostrar logs del Gateway
    if [ -f "gateway-service/logs/app.log" ]; then
        echo "🌐 Gateway Logs:"
        tail -f gateway-service/logs/app.log &
        GATEWAY_LOG_PID=$!
    fi
    
    # Esperar interrupción
    trap "kill $AI_LOG_PID $GATEWAY_LOG_PID 2>/dev/null; exit" INT
    wait
}

# Función principal
main() {
    echo "🕐 $(date)"
    echo ""
    
    # Verificar servicios
    if ! check_services; then
        echo "❌ Algunos servicios no están disponibles"
        echo "   Ejecuta: ./scripts/restart-services.sh"
        exit 1
    fi
    
    # Mostrar configuración
    show_configuration
    
    # Probar endpoints
    test_endpoints
    
    # Mostrar instrucciones
    show_test_instructions
    
    # Preguntar si quiere monitorear logs
    echo ""
    read -p "¿Quieres monitorear logs en tiempo real? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        show_logs
    fi
}

# Ejecutar función principal
main 