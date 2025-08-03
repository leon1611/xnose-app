#!/bin/bash

echo "🚀 CONFIGURACIÓN AUTOMÁTICA COMPLETA DE X-NOSE"
echo "=============================================="
echo ""

# Función para validar URL de GitHub
validate_github_url() {
    local url=$1
    if [[ $url =~ ^https://github\.com/[^/]+/[^/]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Función para validar URL de base de datos
validate_db_url() {
    local url=$1
    if [[ $url =~ ^postgresql://.*:.*@.*:.*/.*$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "📋 RECOPILANDO INFORMACIÓN NECESARIA"
echo "===================================="
echo ""

# 1. URL del repositorio GitHub
while true; do
    echo "🌐 URL del repositorio GitHub:"
    echo "   Ejemplo: https://github.com/tu-usuario/xnose"
    read -p "   Ingresa la URL: " GITHUB_REPO
    
    if validate_github_url "$GITHUB_REPO"; then
        break
    else
        echo "   ❌ URL inválida. Asegúrate de que sea: https://github.com/usuario/repositorio"
    fi
done

# 2. API Key de Render
echo ""
echo "🔑 API Key de Render:"
echo "   (La obtuviste de: https://dashboard.render.com/account/api-keys)"
read -p "   Ingresa la API Key: " RENDER_API_KEY

# 3. Account ID de Render
echo ""
echo "🆔 Account ID de Render:"
echo "   (Lo obtienes de: https://dashboard.render.com/account)"
read -p "   Ingresa el Account ID: " RENDER_ACCOUNT_ID

# 4. URL de la base de datos
while true; do
    echo ""
    echo "🗄️ URL de la base de datos PostgreSQL:"
    echo "   Ejemplo: postgresql://xnose_user:password@host:port/xnose_db"
    read -p "   Ingresa la URL: " DATABASE_URL
    
    if validate_db_url "$DATABASE_URL"; then
        break
    else
        echo "   ❌ URL inválida. Asegúrate de que sea una URL PostgreSQL válida"
    fi
done

# 5. Password de la base de datos
echo ""
echo "🔐 Password de la base de datos:"
read -s -p "   Ingresa el password: " DATABASE_PASSWORD
echo ""

echo ""
echo "✅ INFORMACIÓN RECOPILADA"
echo "========================"
echo "   GitHub Repo: $GITHUB_REPO"
echo "   Render API Key: ${RENDER_API_KEY:0:10}..."
echo "   Render Account ID: $RENDER_ACCOUNT_ID"
echo "   Database URL: ${DATABASE_URL:0:30}..."
echo ""

read -p "¿Continuar con la configuración automática? (y/N): " confirm

if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo "❌ Configuración cancelada"
    exit 0
fi

echo ""
echo "🚀 INICIANDO CONFIGURACIÓN AUTOMÁTICA"
echo "===================================="

# Configurar Git remote
echo "📤 Configurando Git remote..."
git remote add origin "$GITHUB_REPO" 2>/dev/null || git remote set-url origin "$GITHUB_REPO"

# Hacer push al repositorio
echo "📤 Subiendo código a GitHub..."
if git push -u origin main; then
    echo "   ✅ Código subido exitosamente"
else
    echo "   ❌ Error subiendo código. Verifica la URL del repositorio"
    exit 1
fi

# Generar JWT Secret
JWT_SECRET=$(openssl rand -base64 64)

echo ""
echo "🔧 CONFIGURANDO SERVICIOS EN RENDER..."

# Función para crear servicio en Render
create_render_service() {
    local service_name=$1
    local dockerfile_path=$2
    local docker_context=$3
    local env_vars=$4
    local health_check_path=$5

    echo "   🔧 Creando $service_name..."
    
    local response=$(curl -s -X POST "https://api.render.com/v1/services" \
        -H "Authorization: Bearer $RENDER_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"name\": \"$service_name\",
            \"type\": \"web\",
            \"repo\": \"$GITHUB_REPO\",
            \"branch\": \"main\",
            \"dockerfilePath\": \"$dockerfile_path\",
            \"dockerContext\": \"$docker_context\",
            \"envVars\": $env_vars,
            \"healthCheckPath\": \"$health_check_path\",
            \"autoDeploy\": true
        }")

    local service_id=$(echo "$response" | jq -r '.id')
    
    if [ "$service_id" != "null" ] && [ "$service_id" != "" ]; then
        echo "      ✅ $service_name creado: $service_id"
        echo "$service_id" >> .render_service_ids
        return 0
    else
        echo "      ❌ Error creando $service_name: $(echo "$response" | jq -r '.message')"
        return 1
    fi
}

# Variables de entorno para AI Service
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

# Variables de entorno para servicios con base de datos
DB_ENV_VARS=$(cat <<EOF
{
  "SPRING_PROFILES_ACTIVE": "production",
  "SPRING_DATASOURCE_URL": "$DATABASE_URL",
  "SPRING_DATASOURCE_USERNAME": "xnose_user",
  "SPRING_DATASOURCE_PASSWORD": "$DATABASE_PASSWORD",
  "JWT_SECRET": "$JWT_SECRET",
  "JWT_EXPIRATION": "86400000",
  "LOG_LEVEL": "INFO"
}
EOF
)

# Variables de entorno para Pet Service
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

# Variables de entorno para Gateway Service
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

# Variables de entorno para Frontend
FRONTEND_ENV_VARS=$(cat <<EOF
{
  "EXPO_PUBLIC_API_URL": "https://xnose-gateway.onrender.com",
  "EXPO_PUBLIC_AI_SERVICE_URL": "https://xnose-ai-service.onrender.com",
  "EXPO_PUBLIC_GCS_BUCKET_URL": "https://storage.googleapis.com/xnose-pet-images",
  "NODE_ENV": "production"
}
EOF
)

# Inicializar archivo de IDs
echo "" > .render_service_ids

# Crear servicios en orden
echo ""
echo "🔧 Creando servicios..."

# 1. AI Service
if create_render_service "xnose-ai-service" "./ai-service/Dockerfile" "./ai-service" "$AI_ENV_VARS" "/health"; then
    AI_SERVICE_ID=$(tail -n 1 .render_service_ids)
else
    echo "❌ Error creando AI Service"
    exit 1
fi

# 2. Auth Service
if create_render_service "xnose-auth-service" "./auth-service/Dockerfile" "./auth-service" "$DB_ENV_VARS" "/actuator/health"; then
    AUTH_SERVICE_ID=$(tail -n 1 .render_service_ids)
else
    echo "❌ Error creando Auth Service"
    exit 1
fi

# 3. Owner Service
if create_render_service "xnose-owner-service" "./owner-service/Dockerfile" "./owner-service" "$DB_ENV_VARS" "/actuator/health"; then
    OWNER_SERVICE_ID=$(tail -n 1 .render_service_ids)
else
    echo "❌ Error creando Owner Service"
    exit 1
fi

# 4. Pet Service
if create_render_service "xnose-pet-service" "./pet-service/Dockerfile" "./pet-service" "$PET_ENV_VARS" "/actuator/health"; then
    PET_SERVICE_ID=$(tail -n 1 .render_service_ids)
else
    echo "❌ Error creando Pet Service"
    exit 1
fi

# 5. Alert Service
if create_render_service "xnose-alert-service" "./alert-service/Dockerfile" "./alert-service" "$DB_ENV_VARS" "/actuator/health"; then
    ALERT_SERVICE_ID=$(tail -n 1 .render_service_ids)
else
    echo "❌ Error creando Alert Service"
    exit 1
fi

# 6. Gateway Service
if create_render_service "xnose-gateway" "./gateway-service/Dockerfile" "./gateway-service" "$GATEWAY_ENV_VARS" "/actuator/health"; then
    GATEWAY_SERVICE_ID=$(tail -n 1 .render_service_ids)
else
    echo "❌ Error creando Gateway Service"
    exit 1
fi

# 7. Frontend
if create_render_service "xnose-frontend" "./frontend/Dockerfile" "./frontend" "$FRONTEND_ENV_VARS" "/health"; then
    FRONTEND_SERVICE_ID=$(tail -n 1 .render_service_ids)
else
    echo "❌ Error creando Frontend"
    exit 1
fi

echo ""
echo "🎉 ¡CONFIGURACIÓN COMPLETADA!"
echo "============================="
echo ""
echo "📋 Servicios creados:"
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
echo "⏳ Los servicios pueden tardar 5-10 minutos en estar completamente listos"
echo ""
echo "📊 Para verificar el despliegue:"
echo "   ./scripts/verify-deployment.sh"
echo ""
echo "🚀 ¡Tu aplicación X-NOSE está desplegada en Render!" 