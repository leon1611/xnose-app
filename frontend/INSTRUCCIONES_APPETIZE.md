# 🚀 Instrucciones para Appetize.io

## 📋 Pasos para generar APK:

### 1️⃣ Ir a Appetize.io
- Ve a: https://appetize.io
- Crea una cuenta gratuita
- Inicia sesión

### 2️⃣ Crear nuevo proyecto
- Haz clic en "New App"
- Nombre: "X-NOSE"
- Plataforma: Android
- Sube el archivo: `xnose-app-appetize.zip`

### 3️⃣ Configurar variables de entorno
En la sección "Environment Variables", agrega:
```
EXPO_PUBLIC_API_URL=https://xnose-gateway-service-431223568957.us-central1.run.app
EXPO_PUBLIC_AI_SERVICE_URL=https://xnose-ai-service-jrms6vnyga-uc.a.run.app
EXPO_PUBLIC_GCS_BUCKET_URL=https://storage.googleapis.com/petnow-dogs-images-app-biometrico-db
```

### 4️⃣ Configurar build
- Build Type: APK
- Platform: Android
- Framework: React Native/Expo

### 5️⃣ Generar APK
- Haz clic en "Build"
- Espera 5-10 minutos
- ¡APK listo para descargar!

## 📱 Funcionalidades del APK:
- ✅ Registro/Login de usuarios
- ✅ Registro de mascotas con fotos
- ✅ Escaneo de nariz con IA
- ✅ Alertas de mascotas perdidas
- ✅ Perfil de dueño
- ✅ Base de datos persistente

## 🔗 URLs de servicios:
- Gateway: https://xnose-gateway-service-431223568957.us-central1.run.app
- AI Service: https://xnose-ai-service-jrms6vnyga-uc.a.run.app
- Base de datos: PostgreSQL (Google Cloud)
