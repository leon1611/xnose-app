# PetNow Dogs - Frontend

Aplicación móvil React Native con Expo para el sistema de identificación de mascotas mediante huella nasal.

## 🚀 Características

- **Autenticación JWT**: Login y registro de usuarios
- **Registro de Propietarios**: Gestión de información de dueños de mascotas
- **Registro de Mascotas**: Captura de fotos de perfil y nariz
- **Escaneo de Huella Nasal**: Identificación de mascotas mediante IA
- **Sistema de Alertas**: Reporte de mascotas perdidas/encontradas
- **Interfaz Moderna**: Diseño limpio y responsive

## 📱 Pantallas Principales

1. **Login/Register**: Autenticación de usuarios
2. **Dashboard**: Menú principal con navegación
3. **Escanear**: Cámara para capturar huella nasal
4. **Registrar Propietario**: Formulario de datos del dueño
5. **Registrar Mascota**: Formulario con captura de imágenes
6. **Alertas**: Lista y creación de alertas

## 🛠️ Tecnologías

- **React Native** con Expo
- **TypeScript**
- **Expo Router** para navegación
- **Axios** para API calls
- **Expo Camera** para captura de fotos
- **Expo Image Picker** para selección de imágenes
- **AsyncStorage** para persistencia local

## 📦 Instalación

1. **Clonar el repositorio**:

   ```bash
   git clone <repository-url>
   cd XNOSE/frontend
   ```

2. **Instalar dependencias**:

   ```bash
   npm install
   ```

3. **Configurar variables de entorno**:

   - Editar `config/api.ts` con las URLs de tus servicios

4. **Ejecutar la aplicación**:
   ```bash
   npm start
   ```

## 🔧 Configuración

### URLs de API

Edita el archivo `config/api.ts` para configurar las URLs de tus microservicios:

```typescript
export const API_CONFIG = {
  BASE_URL: "http://localhost:8080", // API Gateway
  GCS_BUCKET_URL: "https://storage.googleapis.com/tu-bucket",
  AI_SERVICE_URL: "http://localhost:8000",
  // ...
};
```

### Permisos

La aplicación requiere los siguientes permisos:

- **Cámara**: Para capturar fotos de mascotas
- **Galería**: Para seleccionar imágenes existentes
- **Almacenamiento**: Para guardar datos localmente

## 🚀 Uso

### Desarrollo

```bash
# Iniciar en modo desarrollo
npm start

# Ejecutar en Android
npm run android

# Ejecutar en iOS
npm run ios

# Ejecutar en web
npm run web
```

### Producción

```bash
# Construir para producción
expo build:android
expo build:ios
```

## 📱 Funcionalidades

### Autenticación

- Login con usuario y contraseña
- Registro de nuevos usuarios
- Persistencia de sesión con JWT

### Gestión de Mascotas

- Registro de propietarios
- Registro de mascotas con fotos
- Captura de huella nasal
- Identificación mediante IA

### Sistema de Alertas

- Crear alertas de mascotas perdidas
- Crear alertas de mascotas encontradas
- Lista de alertas activas
- Filtros por tipo de alerta

## 🔗 Integración con Backend

La aplicación se conecta con los siguientes microservicios:

- **Auth Service**: Autenticación JWT
- **Owner Service**: Gestión de propietarios
- **Pet Service**: Gestión de mascotas e imágenes
- **Alert Service**: Sistema de alertas
- **Scan Service**: Identificación por IA
- **AI Service**: Procesamiento de imágenes

## 📄 Estructura del Proyecto

```
frontend/
├── app/
│   ├── (auth)/
│   │   ├── login.tsx
│   │   ├── register.tsx
│   │   └── _layout.tsx
│   ├── (tabs)/
│   │   ├── index.tsx
│   │   ├── scan.tsx
│   │   ├── owner-form.tsx
│   │   ├── pet-register.tsx
│   │   ├── alerts.tsx
│   │   ├── alert-create.tsx
│   │   └── _layout.tsx
│   └── _layout.tsx
├── components/
├── contexts/
│   └── AuthContext.tsx
├── services/
│   └── api.ts
├── config/
│   └── api.ts
└── package.json
```

## 🐛 Solución de Problemas

### Errores Comunes

1. **Error de permisos de cámara**:

   - Verificar permisos en configuración del dispositivo
   - Reiniciar la aplicación

2. **Error de conexión con API**:

   - Verificar URLs en `config/api.ts`
   - Asegurar que los microservicios estén ejecutándose

3. **Error de dependencias**:
   ```bash
   npm install --legacy-peer-deps
   ```

## 📞 Soporte

Para reportar bugs o solicitar nuevas funcionalidades, crear un issue en el repositorio.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.
