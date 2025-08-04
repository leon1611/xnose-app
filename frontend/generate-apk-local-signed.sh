#!/bin/bash

echo "=== 🚀 GENERANDO APK FIRMADO LOCALMENTE ==="
echo "==========================================="

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo "❌ Error: No estás en el directorio frontend"
    exit 1
fi

echo "✅ Directorio correcto"

# Verificar que Java esté instalado
if ! command -v java &> /dev/null; then
    echo "❌ Error: Java no está instalado"
    echo "📦 Instala Java 17 o superior"
    exit 1
fi

echo "✅ Java encontrado: $(java -version 2>&1 | head -1)"

# Verificar que Android SDK esté configurado
if [ -z "$ANDROID_HOME" ]; then
    echo "⚠️  ADVERTENCIA: ANDROID_HOME no está configurado"
    echo "📱 El build puede fallar si no tienes Android SDK"
fi

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm install
npx expo install

# Generar keystore
echo "🔑 Generando keystore..."
if [ ! -f "android/app/xnose-release-key.keystore" ]; then
    keytool -genkey -v \
        -keystore android/app/xnose-release-key.keystore \
        -alias xnose-key-alias \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storepass xnose2024 \
        -keypass xnose2024 \
        -dname "CN=X-NOSE, OU=Development, O=PetNow, L=City, S=State, C=US"
    echo "✅ Keystore generado"
else
    echo "✅ Keystore ya existe"
fi

# Construir APK
echo "🏗️  Construyendo APK firmado..."
cd android
./gradlew assembleRelease

# Verificar que el APK se generó
if [ -f "app/build/outputs/apk/release/app-release.apk" ]; then
    echo "✅ APK generado exitosamente!"
    echo "📱 Archivo: app/build/outputs/apk/release/app-release.apk"
    echo "📏 Tamaño: $(ls -lh app/build/outputs/apk/release/app-release.apk | awk '{print $5}')"
    
    # Abrir la carpeta
    echo "📂 Abriendo carpeta..."
    open app/build/outputs/apk/release/
else
    echo "❌ Error: APK no se generó"
    exit 1
fi 