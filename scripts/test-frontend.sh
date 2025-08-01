#!/bin/bash

# Script para probar la funcionalidad del frontend con el gateway
echo "🧪 Probando funcionalidad del Frontend con Gateway..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para probar endpoint
test_endpoint() {
    local endpoint=$1
    local description=$2
    local method=${3:-GET}
    local data=${4:-""}
    
    echo -e "${BLUE}🔗 Probando: $description${NC}"
    
    if [ "$method" = "POST" ] && [ -n "$data" ]; then
        response=$(curl -s -w "%{http_code}" -X POST "http://localhost:8080$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data" 2>/dev/null)
    else
        response=$(curl -s -w "%{http_code}" "http://localhost:8080$endpoint" 2>/dev/null)
    fi
    
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo -e "${GREEN}✅ $description - HTTP $http_code${NC}"
        if [ -n "$body" ]; then
            echo "   📄 Respuesta: $body"
        fi
        return 0
    elif [ "$http_code" = "404" ]; then
        echo -e "${YELLOW}⚠️  $description - HTTP $http_code (Endpoint no encontrado)${NC}"
        return 1
    elif [ "$http_code" = "500" ]; then
        echo -e "${RED}❌ $description - HTTP $http_code (Error interno)${NC}"
        return 1
    else
        echo -e "${RED}❌ $description - HTTP $http_code${NC}"
        return 1
    fi
}

echo -e "${BLUE}📋 Iniciando pruebas del Frontend...${NC}"
echo ""

# 1. Probar Health Check del Gateway
test_endpoint "/actuator/health" "Health Check del Gateway"

# 2. Probar Auth Service
echo ""
echo -e "${BLUE}🔐 Probando Auth Service...${NC}"
test_endpoint "/auth/health" "Health Check del Auth Service"

# 3. Probar registro de usuario
echo ""
echo -e "${BLUE}👤 Probando registro de usuario...${NC}"
test_endpoint "/auth/register" "Registro de usuario" "POST" '{"username":"testuser","email":"test@example.com","password":"password123"}'

# 4. Probar login de usuario
echo ""
echo -e "${BLUE}🔑 Probando login de usuario...${NC}"
test_endpoint "/auth/login" "Login de usuario" "POST" '{"username":"testuser","password":"password123"}'

# 5. Probar Owner Service
echo ""
echo -e "${BLUE}👥 Probando Owner Service...${NC}"
test_endpoint "/owners" "Listar propietarios"

# 6. Probar crear propietario
echo ""
echo -e "${BLUE}➕ Probando crear propietario...${NC}"
test_endpoint "/owners" "Crear propietario" "POST" '{"name":"Leon Test","email":"leon@test.com","phone":"+593984218613","address":"Cuenca, Ecuador"}'

# 7. Probar Pet Service
echo ""
echo -e "${BLUE}🐕 Probando Pet Service...${NC}"
test_endpoint "/pets" "Listar mascotas"

# 8. Probar Alert Service
echo ""
echo -e "${BLUE}🚨 Probando Alert Service...${NC}"
test_endpoint "/alerts" "Listar alertas"

# 9. Probar crear alerta
echo ""
echo -e "${BLUE}➕ Probando crear alerta...${NC}"
test_endpoint "/alerts" "Crear alerta" "POST" '{"petId":"1877cf46-c9ee-486f-8bb6-295185c73927","type":"LOST","location":"Parque Central","description":"Mascota perdida para pruebas"}'

# 10. Probar AI Service
echo ""
echo -e "${BLUE}🤖 Probando AI Service...${NC}"
test_endpoint "/ai/health" "Health Check del AI Service"

echo ""
echo -e "${BLUE}📊 Resumen de pruebas:${NC}"
echo -e "${YELLOW}✅ Pruebas completadas${NC}"
echo ""
echo -e "${BLUE}💡 Para probar desde el frontend móvil:${NC}"
echo "   1. Abrir Expo Go en tu dispositivo"
echo "   2. Escanear el código QR: exp://192.168.0.104:19001"
echo "   3. Probar las funcionalidades en la app"
echo ""
echo -e "${BLUE}🔧 Para ver logs del frontend:${NC}"
echo "   tail -f frontend/logs/app.log" 