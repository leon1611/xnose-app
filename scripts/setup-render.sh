#!/bin/bash

echo "🚀 CONFIGURACIÓN AUTOMÁTICA DE RENDER PARA X-NOSE"
echo "================================================="
echo ""

# Verificar si curl está instalado
if ! command -v curl &> /dev/null; then
    echo "❌ curl no está instalado. Instálalo primero."
    exit 1
fi

# Verificar si jq está instalado
if ! command -v jq &> /dev/null; then
    echo "❌ jq no está instalado. Instálalo con: brew install jq"
    exit 1
fi

# Solicitar información necesaria
echo "📋 Configuración de Render:"
read -p "Ingresa tu API Key de Render: " RENDER_API_KEY
read -p "Ingresa el ID de tu cuenta de Render: " RENDER_ACCOUNT_ID
read -p "Ingresa el nombre del repositorio en GitHub (ej: tu-usuario/xnose): " GITHUB_REPO
read -p "Ingresa la URL de tu base de datos PostgreSQL en Render: " DATABASE_URL
read -p "Ingresa el password de la base de datos: " DATABASE_PASSWORD

# Configurar variables de entorno
echo ""
echo "🔧 Configurando variables de entorno..."

# JWT Secret aleatorio
JWT_SECRET=$(openssl rand -base64 64)

# Variables comunes para todos los servicios
COMMON_ENV_VARS=$(cat <<EOF
{
  "SPRING_PROFILES_ACTIVE": "production",
  "JWT_SECRET": "$JWT_SECRET",
  "JWT_EXPIRATION": "86400000",
  "LOG_LEVEL": "INFO"
}
EOF
)

# Variables para servicios con base de datos
DB_ENV_VARS=$(cat <<EOF
{
  "SPRING_DATASOURCE_URL": "$DATABASE_URL",
  "SPRING_DATASOURCE_USERNAME": "xnose_user",
  "SPRING_DATASOURCE_PASSWORD": "$DATABASE_PASSWORD"
}
EOF
)

# Función para crear un servicio en Render
create_service() {
    local service_name=$1
    local service_type=$2
    local dockerfile_path=$3
    local docker_context=$4
    local port=$5
    local env_vars=$6
    local health_check_path=$7

    echo "🔧 Creando servicio: $service_name"
    
    # Crear el servicio
    local create_response=$(curl -s -X POST "https://api.render.com/v1/services" \
        -H "Authorization: Bearer $RENDER_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"$service_name\",
            \"type\": \"$service_type\",
            \"repo\": \"$GITHUB_REPO\",
            \"branch\": \"main\",
            \"dockerfilePath\": \"$dockerfile_path\",
            \"dockerContext\": \"$docker_context\",
            \"envVars\": $env_vars,
            \"healthCheckPath\": \"$health_check_path\",
            \"autoDeploy\": true
        }")

    local service_id=$(echo "$create_response" | jq -r '.id')
    
    if [ "$service_id" != "null" ] && [ "$service_id" != "" ]; then
        echo "   ✅ Servicio creado: $service_id"
        echo "$service_id" >> .render_service_ids
        return 0
    else
        echo "   ❌ Error creando servicio: $(echo "$create_response" | jq -r '.message')"
        return 1
    fi
}

# Función para crear base de datos PostgreSQL
create_database() {
    echo "🗄️ Creando base de datos PostgreSQL..."
    
    local db_response=$(curl -s -X POST "https://api.render.com/v1/databases" \
        -H "Authorization: Bearer $RENDER_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"xnose-database\",
            \"databaseName\": \"xnose_db\",
            \"user\": \"xnose_user\",
            \"plan\": \"free\"
        }")

    local db_id=$(echo "$db_response" | jq -r '.id')
    
    if [ "$db_id" != "null" ] && [ "$db_id" != "" ]; then
        echo "   ✅ Base de datos creada: $db_id"
        echo "$db_id" > .render_database_id
        return 0
    else
        echo "   ❌ Error creando base de datos: $(echo "$db_response" | jq -r '.message')"
        return 1
    fi
}

# Función para esperar a que un servicio esté listo
wait_for_service() {
    local service_id=$1
    local service_name=$2
    
    echo "⏳ Esperando a que $service_name esté listo..."
    
    for i in {1..30}; do
        local status_response=$(curl -s -X GET "https://api.render.com/v1/services/$service_id" \
            -H "Authorization: Bearer $RENDER_API_KEY")
        
        local status=$(echo "$status_response" | jq -r '.status')
        
        if [ "$status" = "live" ]; then
            echo "   ✅ $service_name está listo!"
            return 0
        elif [ "$status" = "failed" ]; then
            echo "   ❌ $service_name falló al desplegar"
            return 1
        fi
        
        echo "   ⏳ Estado: $status (intento $i/30)"
        sleep 30
    done
    
    echo "   ⚠️ Timeout esperando $service_name"
    return 1
}

# Inicializar archivo de IDs de servicios
echo "" > .render_service_ids

# Crear base de datos
if create_database; then
    echo "✅ Base de datos configurada"
else
    echo "❌ Error configurando base de datos"
    exit 1
fi

# Variables para AI Service
AI_ENV_VARS=$(cat <<EOF
{
  "PYTHONUNBUFFERED": "1",
  "HOST": "0.0.0.0",
  "PORT": "8000",
  "LOG_LEVEL": "INFO",
  "SIMILARITY_THRESHOLD": "0.80",
  "CONFIDENCE_BOOST": "0.1",
  "EMBEDDINGS_FILE": "nose_print_embeddings.json",
  "AUDIT_LOG_FILE": "requests.log",
  "GCS_ENABLED": "false",
  "CORS_ORIGINS": "https://*.onrender.com,https://*.vercel.app,http://localhost:19000,http://localhost:3000"
}
EOF
)

# Variables para Pet Service
PET_ENV_VARS=$(cat <<EOF
{
  "SPRING_PROFILES_ACTIVE": "production",
  "SPRING_DATASOURCE_URL": "$DATABASE_URL",
  "SPRING_DATASOURCE_USERNAME": "xnose_user",
  "SPRING_DATASOURCE_PASSWORD": "$DATABASE_PASSWORD",
  "AI_SERVICE_URL": "https://xnose-ai-service.onrender.com",
  "AI_SERVICE_ENABLED": "true",
  "GCS_ENABLED": "false",
  "JWT_SECRET": "$JWT_SECRET",
  "JWT_EXPIRATION": "86400000",
  "LOG_LEVEL": "INFO"
}
EOF
)

# Variables para Gateway Service
GATEWAY_ENV_VARS=$(cat <<EOF
{
  "SPRING_PROFILES_ACTIVE": "production",
  "SPRING_DATASOURCE_URL": "$DATABASE_URL",
  "SPRING_DATASOURCE_USERNAME": "xnose_user",
  "SPRING_DATASOURCE_PASSWORD": "$DATABASE_PASSWORD",
  "AUTH_SERVICE_URL": "https://xnose-auth-service.onrender.com",
  "OWNER_SERVICE_URL": "https://xnose-owner-service.onrender.com",
  "PET_SERVICE_URL": "https://xnose-pet-service.onrender.com",
  "ALERT_SERVICE_URL": "https://xnose-alert-service.onrender.com",
  "AI_SERVICE_URL": "https://xnose-ai-service.onrender.com",
  "JWT_SECRET": "$JWT_SECRET",
  "JWT_EXPIRATION": "86400000",
  "LOG_LEVEL": "INFO"
}
EOF
)

# Variables para Frontend
FRONTEND_ENV_VARS=$(cat <<EOF
{
  "EXPO_PUBLIC_API_URL": "https://xnose-gateway.onrender.com",
  "EXPO_PUBLIC_AI_SERVICE_URL": "https://xnose-ai-service.onrender.com",
  "EXPO_PUBLIC_GCS_BUCKET_URL": "https://storage.googleapis.com/xnose-pet-images",
  "NODE_ENV": "production"
}
EOF
)

echo ""
echo "🔧 Creando servicios en orden..."

# 1. AI Service (primero porque otros dependen de él)
if create_service "xnose-ai-service" "web" "./ai-service/Dockerfile" "./ai-service" "8000" "$AI_ENV_VARS" "/health"; then
    AI_SERVICE_ID=$(tail -n 1 .render_service_ids)
    wait_for_service "$AI_SERVICE_ID" "AI Service"
else
    echo "❌ Error creando AI Service"
    exit 1
fi

# 2. Auth Service
AUTH_ENV_VARS=$(echo "$COMMON_ENV_VARS" | jq -s '.[0] + .[1]' - <(echo "$DB_ENV_VARS"))
if create_service "xnose-auth-service" "web" "./auth-service/Dockerfile" "./auth-service" "8081" "$AUTH_ENV_VARS" "/actuator/health"; then
    AUTH_SERVICE_ID=$(tail -n 1 .render_service_ids)
    wait_for_service "$AUTH_SERVICE_ID" "Auth Service"
else
    echo "❌ Error creando Auth Service"
    exit 1
fi

# 3. Owner Service
OWNER_ENV_VARS=$(echo "$COMMON_ENV_VARS" | jq -s '.[0] + .[1]' - <(echo "$DB_ENV_VARS"))
if create_service "xnose-owner-service" "web" "./owner-service/Dockerfile" "./owner-service" "8082" "$OWNER_ENV_VARS" "/actuator/health"; then
    OWNER_SERVICE_ID=$(tail -n 1 .render_service_ids)
    wait_for_service "$OWNER_SERVICE_ID" "Owner Service"
else
    echo "❌ Error creando Owner Service"
    exit 1
fi

# 4. Pet Service
if create_service "xnose-pet-service" "web" "./pet-service/Dockerfile" "./pet-service" "8083" "$PET_ENV_VARS" "/actuator/health"; then
    PET_SERVICE_ID=$(tail -n 1 .render_service_ids)
    wait_for_service "$PET_SERVICE_ID" "Pet Service"
else
    echo "❌ Error creando Pet Service"
    exit 1
fi

# 5. Alert Service
ALERT_ENV_VARS=$(echo "$COMMON_ENV_VARS" | jq -s '.[0] + .[1]' - <(echo "$DB_ENV_VARS"))
if create_service "xnose-alert-service" "web" "./alert-service/Dockerfile" "./alert-service" "8084" "$ALERT_ENV_VARS" "/actuator/health"; then
    ALERT_SERVICE_ID=$(tail -n 1 .render_service_ids)
    wait_for_service "$ALERT_SERVICE_ID" "Alert Service"
else
    echo "❌ Error creando Alert Service"
    exit 1
fi

# 6. Gateway Service
if create_service "xnose-gateway" "web" "./gateway-service/Dockerfile" "./gateway-service" "8080" "$GATEWAY_ENV_VARS" "/actuator/health"; then
    GATEWAY_SERVICE_ID=$(tail -n 1 .render_service_ids)
    wait_for_service "$GATEWAY_SERVICE_ID" "Gateway Service"
else
    echo "❌ Error creando Gateway Service"
    exit 1
fi

# 7. Frontend
if create_service "xnose-frontend" "web" "./frontend/Dockerfile" "./frontend" "80" "$FRONTEND_ENV_VARS" "/health"; then
    FRONTEND_SERVICE_ID=$(tail -n 1 .render_service_ids)
    wait_for_service "$FRONTEND_SERVICE_ID" "Frontend"
else
    echo "❌ Error creando Frontend"
    exit 1
fi

echo ""
echo "🎉 ¡CONFIGURACIÓN COMPLETADA!"
echo "============================="
echo ""
echo "📋 Servicios creados:"
echo "   🗄️ Base de datos: $(cat .render_database_id)"
echo "   🤖 AI Service: $AI_SERVICE_ID"
echo "   🔐 Auth Service: $AUTH_SERVICE_ID"
echo "   👥 Owner Service: $OWNER_SERVICE_ID"
echo "   🐕 Pet Service: $PET_SERVICE_ID"
echo "   🚨 Alert Service: $ALERT_SERVICE_ID"
echo "   🚪 Gateway Service: $GATEWAY_SERVICE_ID"
echo "   🌐 Frontend: $FRONTEND_SERVICE_ID"
echo ""
echo "🔗 URLs de acceso:"
echo "   Frontend: https://xnose-frontend.onrender.com"
echo "   API Gateway: https://xnose-gateway.onrender.com"
echo "   AI Service: https://xnose-ai-service.onrender.com"
echo ""
echo "📊 Para verificar el despliegue:"
echo "   ./scripts/verify-deployment.sh"
echo ""
echo "⚠️ IMPORTANTE:"
echo "   - Los servicios pueden tardar unos minutos en estar completamente listos"
echo "   - Verifica los logs en Render Dashboard si hay problemas"
echo "   - Configura Google Cloud Storage si necesitas almacenamiento de imágenes"
echo ""
echo "🚀 ¡Tu aplicación X-NOSE está desplegada en Render!" 