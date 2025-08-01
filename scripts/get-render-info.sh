#!/bin/bash

echo "🔍 OBTENIENDO INFORMACIÓN DE RENDER"
echo "==================================="
echo ""

echo "📋 Para configurar Render automáticamente, necesitas:"
echo ""

echo "1. 🔑 API Key de Render:"
echo "   - Ve a https://dashboard.render.com/account/api-keys"
echo "   - Haz clic en 'New API Key'"
echo "   - Copia la API Key generada"
echo ""

echo "2. 🆔 Account ID de Render:"
echo "   - Ve a https://dashboard.render.com/account"
echo "   - El Account ID aparece en la URL o en la información de la cuenta"
echo ""

echo "3. 📦 Repositorio de GitHub:"
echo "   - Asegúrate de que tu código esté en GitHub"
echo "   - El formato es: tu-usuario/nombre-del-repo"
echo "   - Ejemplo: johndoe/xnose"
echo ""

echo "4. 🗄️ Base de datos PostgreSQL:"
echo "   - Ve a https://dashboard.render.com/new/database"
echo "   - Crea una nueva base de datos PostgreSQL"
echo "   - Copia la URL de conexión"
echo "   - Anota el password"
echo ""

echo "5. 🔧 Configuración de GitHub:"
echo "   - Asegúrate de que el repositorio sea público o que Render tenga acceso"
echo "   - Conecta tu cuenta de GitHub a Render si no lo has hecho"
echo ""

echo "📝 Una vez que tengas toda la información, ejecuta:"
echo "   ./scripts/setup-render.sh"
echo ""

echo "🚀 O si prefieres configuración manual:"
echo "   1. Ve a https://dashboard.render.com"
echo "   2. Crea los servicios uno por uno"
echo "   3. Usa los Dockerfiles que ya están configurados"
echo ""

echo "📚 Documentación adicional:"
echo "   - DEPLOYMENT.md - Guía completa de despliegue"
echo "   - render.yaml - Configuración de servicios"
echo ""

echo "❓ ¿Necesitas ayuda con algún paso específico?" 