#!/bin/bash

echo "🚀 DESPLIEGUE AUTOMATIZADO EN RENDER"
echo "===================================="
echo ""

# Verificar si git está configurado
if ! git config --get user.name &> /dev/null; then
    echo "❌ Git no está configurado. Configura tu usuario:"
    echo "   git config --global user.name 'Tu Nombre'"
    echo "   git config --global user.email 'tu@email.com'"
    exit 1
fi

# Verificar si hay cambios sin commitear
if ! git diff-index --quiet HEAD --; then
    echo "📝 Hay cambios sin commitear. Creando commit..."
    git add .
    git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Verificar si el repositorio remoto está configurado
if ! git remote get-url origin &> /dev/null; then
    echo "❌ No hay repositorio remoto configurado."
    echo "📋 Configura el repositorio remoto:"
    echo "   git remote add origin https://github.com/tu-usuario/xnose.git"
    exit 1
fi

# Hacer push al repositorio
echo "📤 Haciendo push al repositorio..."
git push origin main

echo ""
echo "✅ CÓDIGO SUBIDO EXITOSAMENTE"
echo "============================="
echo ""
echo "🔧 CONFIGURACIÓN EN RENDER:"
echo ""
echo "1. Ve a https://dashboard.render.com"
echo "2. Conecta tu repositorio de GitHub"
echo "3. Configura las variables de entorno:"
echo ""
echo "   Variables obligatorias:"
echo "   - SPRING_DATASOURCE_URL"
echo "   - SPRING_DATASOURCE_USERNAME"
echo "   - SPRING_DATASOURCE_PASSWORD"
echo "   - JWT_SECRET"
echo "   - GOOGLE_CLOUD_PROJECT"
echo "   - GCS_BUCKET_NAME"
echo "   - GOOGLE_APPLICATION_CREDENTIALS (contenido del JSON)"
echo ""
echo "4. Despliega los servicios en este orden:"
echo "   - Base de datos PostgreSQL"
echo "   - AI Service"
echo "   - Auth Service"
echo "   - Owner Service"
echo "   - Pet Service"
echo "   - Alert Service"
echo "   - Gateway Service"
echo "   - Frontend"
echo ""
echo "🔗 URLs de los servicios:"
echo "   Gateway: https://xnose-gateway.onrender.com"
echo "   Auth: https://xnose-auth-service.onrender.com"
echo "   Owner: https://xnose-owner-service.onrender.com"
echo "   Pet: https://xnose-pet-service.onrender.com"
echo "   Alert: https://xnose-alert-service.onrender.com"
echo "   AI: https://xnose-ai-service.onrender.com"
echo "   Frontend: https://xnose-frontend.onrender.com"
echo ""
echo "📋 Para verificar el despliegue:"
echo "   ./scripts/verify-deployment.sh"
echo ""
echo "🎉 ¡Despliegue completado!" 