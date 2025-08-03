#!/bin/bash

echo "🚀 CONFIGURACIÓN RÁPIDA DE X-NOSE"
echo "================================="
echo ""

echo "📋 PASOS PARA CONFIGURAR RENDER:"
echo ""

echo "1. 🌐 CREAR REPOSITORIO EN GITHUB:"
echo "   - Ve a https://github.com/new"
echo "   - Nombre: xnose (o el que prefieras)"
echo "   - Descripción: Sistema de identificación biométrica de mascotas"
echo "   - Público (recomendado para Render)"
echo "   - NO inicialices con README (ya tenemos uno)"
echo ""

echo "2. 📤 SUBIR CÓDIGO A GITHUB:"
echo "   Después de crear el repositorio, ejecuta estos comandos:"
echo "   git remote add origin https://github.com/TU_USUARIO/xnose.git"
echo "   git push -u origin main"
echo ""

echo "3. 🗄️ CREAR BASE DE DATOS EN RENDER:"
echo "   - Ve a https://dashboard.render.com/new/database"
echo "   - Nombre: xnose-database"
echo "   - Database: xnose_db"
echo "   - User: xnose_user"
echo "   - Plan: Free"
echo "   - Copia la URL de conexión y el password"
echo ""

echo "4. 🔑 OBTENER API KEY DE RENDER:"
echo "   - Ve a https://dashboard.render.com/account/api-keys"
echo "   - Haz clic en 'New API Key'"
echo "   - Copia la API Key generada"
echo ""

echo "5. 🆔 OBTENER ACCOUNT ID DE RENDER:"
echo "   - Ve a https://dashboard.render.com/account"
echo "   - El Account ID aparece en la URL o en la información"
echo ""

echo "6. 🚀 CONFIGURAR SERVICIOS AUTOMÁTICAMENTE:"
echo "   Una vez que tengas toda la información, ejecuta:"
echo "   ./scripts/setup-render.sh"
echo ""

echo "📝 INFORMACIÓN QUE NECESITARÁS:"
echo "   - URL del repositorio GitHub (ej: https://github.com/tu-usuario/xnose)"
echo "   - API Key de Render"
echo "   - Account ID de Render"
echo "   - URL de la base de datos PostgreSQL"
echo "   - Password de la base de datos"
echo ""

echo "❓ ¿Quieres que te ayude con algún paso específico?"
echo "   1. Crear repositorio en GitHub"
echo "   2. Configurar base de datos en Render"
echo "   3. Obtener API Key de Render"
echo "   4. Configurar todo automáticamente"
echo ""

read -p "Selecciona una opción (1-4) o presiona Enter para continuar: " choice

case $choice in
    1)
        echo ""
        echo "🌐 CREANDO REPOSITORIO EN GITHUB..."
        echo "1. Ve a https://github.com/new"
        echo "2. Llena los campos:"
        echo "   - Repository name: xnose"
        echo "   - Description: Sistema de identificación biométrica de mascotas"
        echo "   - Visibility: Public"
        echo "   - NO marques 'Add a README file'"
        echo "3. Haz clic en 'Create repository'"
        echo "4. Copia la URL del repositorio"
        echo ""
        read -p "Presiona Enter cuando hayas creado el repositorio..."
        ;;
    2)
        echo ""
        echo "🗄️ CONFIGURANDO BASE DE DATOS EN RENDER..."
        echo "1. Ve a https://dashboard.render.com/new/database"
        echo "2. Llena los campos:"
        echo "   - Name: xnose-database"
        echo "   - Database: xnose_db"
        echo "   - User: xnose_user"
        echo "   - Plan: Free"
        echo "3. Haz clic en 'Create Database'"
        echo "4. Copia la URL de conexión y el password"
        echo ""
        read -p "Presiona Enter cuando hayas creado la base de datos..."
        ;;
    3)
        echo ""
        echo "🔑 OBTENIENDO API KEY DE RENDER..."
        echo "1. Ve a https://dashboard.render.com/account/api-keys"
        echo "2. Haz clic en 'New API Key'"
        echo "3. Nombre: xnose-deploy"
        echo "4. Haz clic en 'Create API Key'"
        echo "5. Copia la API Key (no la podrás ver de nuevo)"
        echo ""
        read -p "Presiona Enter cuando hayas creado la API Key..."
        ;;
    4)
        echo ""
        echo "🚀 CONFIGURACIÓN AUTOMÁTICA..."
        echo "Ejecutando script de configuración..."
        ./scripts/setup-render.sh
        ;;
    *)
        echo ""
        echo "✅ Continuando con la configuración manual..."
        ;;
esac

echo ""
echo "🎯 PRÓXIMOS PASOS:"
echo "1. Crea el repositorio en GitHub"
echo "2. Crea la base de datos en Render"
echo "3. Obtén la API Key de Render"
echo "4. Ejecuta: ./scripts/setup-render.sh"
echo ""
echo "📞 ¿Necesitas ayuda con algún paso específico?" 