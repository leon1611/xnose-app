#!/bin/bash

echo "=== 🚀 GENERANDO APK CON CODEMAGIC ==="
echo "======================================"

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: No estás en el directorio frontend"
    exit 1
fi

echo "✅ Directorio correcto"

# Verificar que Codemagic CLI esté instalado
if ! command -v cm-cli &> /dev/null; then
    echo "📦 Instalando Codemagic CLI..."
    npm install -g @codemagic/cli
fi

# Verificar que estés logueado en Codemagic
echo "🔐 Verificando login en Codemagic..."
if ! cm-cli auth whoami &> /dev/null; then
    echo "❌ No estás logueado en Codemagic"
    echo "🔑 Ejecuta: cm-cli auth login"
    exit 1
fi

echo "✅ Logueado en Codemagic"

# Ejecutar build en Codemagic
echo "🏗️  Iniciando build en Codemagic..."
cm-cli builds start \
    --app-id YOUR_APP_ID \
    --workflow-id android-workflow \
    --branch main

echo "✅ Build iniciado en Codemagic"
echo "📱 Ve a https://codemagic.io/apps para ver el progreso"
echo "📧 Recibirás un email cuando termine" 