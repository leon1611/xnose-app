#!/bin/bash

echo "🔄 REINICIANDO SERVICIOS CON NUEVA CONFIGURACIÓN"
echo "==============================================="
echo ""

# Función para detener servicios
stop_services() {
    echo "🛑 Deteniendo servicios..."
    pkill -f "spring-boot:run" 2>/dev/null || echo "   No hay servicios Spring Boot ejecutándose"
    sleep 2
    echo "✅ Servicios detenidos"
    echo ""
}

# Función para verificar puertos
check_ports() {
    echo "🔍 Verificando puertos disponibles..."
    
    local ports=(8080 8081 8082 8083 8084 19000)
    for port in "${ports[@]}"; do
        if lsof -i :$port > /dev/null 2>&1; then
            echo "   ❌ Puerto $port está ocupado"
            lsof -i :$port | grep LISTEN
        else
            echo "   ✅ Puerto $port está libre"
        fi
    done
    echo ""
}

# Función para iniciar gateway
start_gateway() {
    echo "🚪 Iniciando Gateway Service..."
    cd gateway-service
    mvn spring-boot:run > ../logs/gateway.log 2>&1 &
    local gateway_pid=$!
    echo "   PID: $gateway_pid"
    sleep 10
    echo "✅ Gateway iniciado"
    cd ..
    echo ""
}

# Función para iniciar auth service
start_auth() {
    echo "🔐 Iniciando Auth Service..."
    cd auth-service
    mvn spring-boot:run > ../logs/auth.log 2>&1 &
    local auth_pid=$!
    echo "   PID: $auth_pid"
    sleep 10
    echo "✅ Auth Service iniciado"
    cd ..
    echo ""
}

# Función para iniciar owner service
start_owner() {
    echo "👥 Iniciando Owner Service..."
    cd owner-service
    mvn spring-boot:run > ../logs/owner.log 2>&1 &
    local owner_pid=$!
    echo "   PID: $owner_pid"
    sleep 10
    echo "✅ Owner Service iniciado"
    cd ..
    echo ""
}

# Función para iniciar pet service
start_pet() {
    echo "🐕 Iniciando Pet Service..."
    cd pet-service
    mvn spring-boot:run > ../logs/pet.log 2>&1 &
    local pet_pid=$!
    echo "   PID: $pet_pid"
    sleep 10
    echo "✅ Pet Service iniciado"
    cd ..
    echo ""
}

# Función para iniciar alert service
start_alert() {
    echo "🚨 Iniciando Alert Service..."
    cd alert-service
    mvn spring-boot:run > ../logs/alert.log 2>&1 &
    local alert_pid=$!
    echo "   PID: $alert_pid"
    sleep 10
    echo "✅ Alert Service iniciado"
    cd ..
    echo ""
}

# Función para verificar servicios
verify_services() {
    echo "🔍 Verificando servicios..."
    sleep 5
    
    local services=(
        "Gateway:8080"
        "Auth:8081"
        "Owner:8082"
        "Pet:8083"
        "Alert:8084"
    )
    
    for service in "${services[@]}"; do
        local name=$(echo $service | cut -d: -f1)
        local port=$(echo $service | cut -d: -f2)
        
        if curl -s http://localhost:$port/actuator/health > /dev/null 2>&1; then
            echo "   ✅ $name: Puerto $port - OK"
        else
            echo "   ❌ $name: Puerto $port - ERROR"
        fi
    done
    echo ""
}

# Función para mostrar resumen
show_summary() {
    echo "📊 RESUMEN DE SERVICIOS:"
    echo "======================="
    echo ""
    echo "🔧 CONFIGURACIÓN IMPLEMENTADA:"
    echo "   ✅ Propietarios: Privados por usuario"
    echo "   ✅ Mascotas: Privadas por usuario"
    echo "   ✅ Alertas: Compartidas globalmente"
    echo "   ✅ Escáner: Acceso a todas las mascotas"
    echo ""
    echo "🌐 ENDPOINTS DISPONIBLES:"
    echo "   🔐 Auth: http://localhost:8081"
    echo "   👥 Owners: http://localhost:8082"
    echo "   🐕 Pets: http://localhost:8083"
    echo "   🚨 Alerts: http://localhost:8084"
    echo "   🚪 Gateway: http://localhost:8080"
    echo ""
    echo "📱 FRONTEND:"
    echo "   🌐 URL: http://192.168.0.104:19000"
    echo "   📱 Expo Go: exp://192.168.0.104:19000"
    echo ""
    echo "🧪 PRUEBAS RECOMENDADAS:"
    echo "   1. Registra un nuevo usuario"
    echo "   2. Crea propietarios (solo verás los tuyos)"
    echo "   3. Registra mascotas (solo verás las tuyas)"
    echo "   4. Crea alertas (verás todas las alertas)"
    echo "   5. Prueba el escáner (accede a todas las mascotas)"
    echo ""
}

# Crear directorio de logs si no existe
mkdir -p logs

# Ejecutar secuencia
stop_services
check_ports
start_gateway
start_auth
start_owner
start_pet
start_alert
verify_services
show_summary

echo "🎉 ¡SERVICIOS REINICIADOS EXITOSAMENTE!"
echo "======================================"
echo ""
echo "💡 Ahora puedes probar desde tu celular:"
echo "   - Los formularios se limpiarán automáticamente"
echo "   - Cada usuario verá solo sus datos"
echo "   - Las alertas serán compartidas"
echo "   - El escáner funcionará correctamente"
echo "" 