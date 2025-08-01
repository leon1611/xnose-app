#!/bin/bash

echo "🔍 MONITOREO EN TIEMPO REAL DEL FRONTEND"
echo "========================================"
echo ""

# Función para mostrar el estado de los servicios
show_status() {
    echo "📊 ESTADO DE SERVICIOS:"
    echo "----------------------"
    
    # Gateway
    if lsof -i :8080 > /dev/null 2>&1; then
        echo "✅ Gateway: Ejecutándose en puerto 8080"
    else
        echo "❌ Gateway: No está ejecutándose"
    fi
    
    # Frontend
    if lsof -i :19000 > /dev/null 2>&1; then
        echo "✅ Frontend: Ejecutándose en puerto 19000"
    else
        echo "❌ Frontend: No está ejecutándose"
    fi
    
    # Auth Service
    if lsof -i :8081 > /dev/null 2>&1; then
        echo "✅ Auth Service: Ejecutándose en puerto 8081"
    else
        echo "❌ Auth Service: No está ejecutándose"
    fi
    
    echo ""
}

# Función para mostrar conexiones activas
show_connections() {
    echo "📱 CONEXIONES ACTIVAS:"
    echo "---------------------"
    
    # Conexiones al Gateway
    echo "🔗 Conexiones al Gateway (8080):"
    lsof -i :8080 | grep ESTABLISHED | wc -l | xargs echo "   - Conexiones establecidas:"
    
    # Conexiones al Frontend
    echo "📱 Conexiones al Frontend (19000):"
    lsof -i :19000 | grep ESTABLISHED | wc -l | xargs echo "   - Conexiones establecidas:"
    
    echo ""
}

# Función para probar endpoints
test_endpoints() {
    echo "🧪 PRUEBA RÁPIDA DE ENDPOINTS:"
    echo "-----------------------------"
    
    # Test Gateway Health
    echo "🔍 Probando Gateway Health..."
    if curl -s http://192.168.0.104:8080/actuator/health > /dev/null; then
        echo "   ✅ Gateway Health: OK"
    else
        echo "   ❌ Gateway Health: ERROR"
    fi
    
    # Test Auth Health
    echo "🔐 Probando Auth Health..."
    if curl -s http://192.168.0.104:8080/auth/health > /dev/null; then
        echo "   ✅ Auth Health: OK"
    else
        echo "   ❌ Auth Health: ERROR"
    fi
    
    echo ""
}

# Función para mostrar logs recientes
show_recent_activity() {
    echo "📝 ACTIVIDAD RECIENTE:"
    echo "---------------------"
    
    # Mostrar las últimas conexiones establecidas
    echo "🔄 Últimas conexiones establecidas:"
    lsof -i :8080 | grep ESTABLISHED | tail -3 | while read line; do
        echo "   📱 $line"
    done
    
    echo ""
}

# Bucle principal de monitoreo
while true; do
    clear
    echo "🕐 $(date)"
    echo "========================================"
    
    show_status
    show_connections
    test_endpoints
    show_recent_activity
    
    echo "💡 Presiona Ctrl+C para salir"
    echo "🔄 Actualizando en 5 segundos..."
    sleep 5
done 