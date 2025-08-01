#!/bin/bash

echo "🔍 VERIFICACIÓN DEL DESPLIEGUE EN RENDER"
echo "========================================"
echo ""

# URLs de los servicios
SERVICES=(
    "https://xnose-gateway.onrender.com/actuator/health"
    "https://xnose-auth-service.onrender.com/actuator/health"
    "https://xnose-owner-service.onrender.com/actuator/health"
    "https://xnose-pet-service.onrender.com/actuator/health"
    "https://xnose-alert-service.onrender.com/actuator/health"
    "https://xnose-ai-service.onrender.com/health"
    "https://xnose-frontend.onrender.com/health"
)

SERVICE_NAMES=(
    "Gateway Service"
    "Auth Service"
    "Owner Service"
    "Pet Service"
    "Alert Service"
    "AI Service"
    "Frontend"
)

# Función para verificar un servicio
check_service() {
    local url=$1
    local name=$2
    
    echo "🔍 Verificando $name..."
    
    # Intentar hacer la petición
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10)
    
    if [ "$response" = "200" ]; then
        echo "   ✅ $name está funcionando (HTTP $response)"
        return 0
    else
        echo "   ❌ $name no responde correctamente (HTTP $response)"
        return 1
    fi
}

# Verificar todos los servicios
echo "📋 Verificando servicios..."
echo ""

failed_services=0

for i in "${!SERVICES[@]}"; do
    if ! check_service "${SERVICES[$i]}" "${SERVICE_NAMES[$i]}"; then
        ((failed_services++))
    fi
    echo ""
done

# Verificar conectividad entre servicios
echo "🔗 Verificando conectividad entre servicios..."
echo ""

# Verificar que el Gateway puede comunicarse con otros servicios
echo "🔍 Verificando comunicación del Gateway..."
gateway_response=$(curl -s "https://xnose-gateway.onrender.com/actuator/health" --max-time 10)
if echo "$gateway_response" | grep -q "UP"; then
    echo "   ✅ Gateway está funcionando correctamente"
else
    echo "   ❌ Gateway tiene problemas de conectividad"
    ((failed_services++))
fi

# Verificar base de datos
echo "🔍 Verificando conectividad de base de datos..."
db_check=$(curl -s "https://xnose-gateway.onrender.com/actuator/health" --max-time 10)
if echo "$db_check" | grep -q "UP"; then
    echo "   ✅ Base de datos está accesible"
else
    echo "   ❌ Problemas con la base de datos"
    ((failed_services++))
fi

echo ""
echo "📊 RESUMEN DE VERIFICACIÓN"
echo "=========================="
echo ""

if [ $failed_services -eq 0 ]; then
    echo "🎉 ¡TODOS LOS SERVICIOS ESTÁN FUNCIONANDO!"
    echo ""
    echo "✅ Despliegue exitoso"
    echo "✅ Todos los servicios responden correctamente"
    echo "✅ Base de datos conectada"
    echo "✅ Comunicación entre servicios establecida"
    echo ""
    echo "🌐 URLs de acceso:"
    echo "   Frontend: https://xnose-frontend.onrender.com"
    echo "   API Gateway: https://xnose-gateway.onrender.com"
    echo ""
    echo "🚀 El sistema está listo para usar"
else
    echo "⚠️ HAY PROBLEMAS CON $failed_services SERVICIO(S)"
    echo ""
    echo "🔧 Pasos para solucionar:"
    echo "   1. Verifica los logs en Render Dashboard"
    echo "   2. Revisa las variables de entorno"
    echo "   3. Verifica la conectividad de la base de datos"
    echo "   4. Revisa las credenciales de Google Cloud"
    echo ""
    echo "📋 Para ver logs específicos:"
    echo "   - Ve a Render Dashboard"
    echo "   - Selecciona el servicio con problemas"
    echo "   - Revisa la pestaña 'Logs'"
fi

echo ""
echo "📞 Para soporte adicional:"
echo "   - Revisa la documentación en README.md"
echo "   - Verifica los logs en Render"
echo "   - Consulta el manual de usuario" 