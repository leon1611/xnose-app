#!/bin/bash

# Script para verificar que el Gateway esté funcionando correctamente
# con todos los servicios locales

echo "🔍 Verificando configuración del Gateway Service..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para verificar si un puerto está abierto
check_port() {
    local port=$1
    local service=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${GREEN}✅ $service (puerto $port) está ejecutándose${NC}"
        return 0
    else
        echo -e "${RED}❌ $service (puerto $port) NO está ejecutándose${NC}"
        return 1
    fi
}

# Función para verificar endpoint del gateway
check_gateway_endpoint() {
    local endpoint=$1
    local description=$2
    local url="http://localhost:8080$endpoint"
    
    echo -e "${BLUE}🔗 Probando: $description${NC}"
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$response" = "200" ] || [ "$response" = "404" ] || [ "$response" = "401" ]; then
        echo -e "${GREEN}✅ Gateway responde correctamente a $endpoint (HTTP $response)${NC}"
        return 0
    else
        echo -e "${RED}❌ Gateway NO responde a $endpoint (HTTP $response)${NC}"
        return 1
    fi
}

echo -e "${BLUE}📋 Verificando puertos de servicios...${NC}"
echo ""

# Verificar que todos los servicios estén ejecutándose
check_port 8080 "Gateway Service"
check_port 8081 "Auth Service"
check_port 8082 "Owner Service"
check_port 8083 "Pet Service"
check_port 8084 "Alert Service"
check_port 8000 "AI Service"

echo ""
echo -e "${BLUE}🔗 Verificando enrutamiento del Gateway...${NC}"
echo ""

# Verificar endpoints del gateway
check_gateway_endpoint "/actuator/health" "Health Check del Gateway"
check_gateway_endpoint "/auth/health" "Ruta Auth Service"
check_gateway_endpoint "/owners" "Ruta Owner Service"
check_gateway_endpoint "/pets" "Ruta Pet Service"
check_gateway_endpoint "/alerts" "Ruta Alert Service"
check_gateway_endpoint "/ai/health" "Ruta AI Service"

echo ""
echo -e "${BLUE}🔧 Verificando configuración de archivos...${NC}"
echo ""

# Verificar archivos de configuración
if [ -f "gateway-service/src/main/resources/application.yml" ]; then
    echo -e "${GREEN}✅ Archivo de configuración del Gateway encontrado${NC}"
else
    echo -e "${RED}❌ Archivo de configuración del Gateway NO encontrado${NC}"
fi

if [ -f "frontend/config/api.ts" ]; then
    echo -e "${GREEN}✅ Archivo de configuración del Frontend encontrado${NC}"
else
    echo -e "${RED}❌ Archivo de configuración del Frontend NO encontrado${NC}"
fi

echo ""
echo -e "${BLUE}📊 Resumen de configuración:${NC}"
echo ""

# Mostrar configuración actual
echo -e "${YELLOW}Gateway Service:${NC} http://localhost:8080"
echo -e "${YELLOW}Auth Service:${NC} http://localhost:8081"
echo -e "${YELLOW}Owner Service:${NC} http://localhost:8082"
echo -e "${YELLOW}Pet Service:${NC} http://localhost:8083"
echo -e "${YELLOW}Alert Service:${NC} http://localhost:8084"
echo -e "${YELLOW}AI Service:${NC} http://localhost:8000"

echo ""
echo -e "${BLUE}🎯 Rutas del Gateway:${NC}"
echo -e "${YELLOW}/auth/**${NC} → Auth Service (8081)"
echo -e "${YELLOW}/owners/**${NC} → Owner Service (8082)"
echo -e "${YELLOW}/pets/**${NC} → Pet Service (8083)"
echo -e "${YELLOW}/alerts/**${NC} → Alert Service (8084)"
echo -e "${YELLOW}/ai/**${NC} → AI Service (8000)"

echo ""
echo -e "${GREEN}✅ Verificación completada${NC}"
echo ""
echo -e "${BLUE}💡 Para iniciar todos los servicios:${NC}"
echo "   ./start-project.sh"
echo ""
echo -e "${BLUE}💡 Para ver logs del Gateway:${NC}"
echo "   tail -f gateway-service/logs/app.log" 