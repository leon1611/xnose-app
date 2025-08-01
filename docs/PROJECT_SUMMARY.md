# 📋 Resumen del Proyecto PETNOW-DOGS

## 🎯 Descripción General

PETNOW-DOGS es un sistema completo de identificación de perros por huella nasal que utiliza una arquitectura de microservicios y inteligencia artificial. El proyecto incluye un backend robusto con múltiples servicios y una aplicación móvil moderna.

## 🏗️ Arquitectura del Sistema

### Backend (Microservicios)
- **Auth Service**: Autenticación JWT y gestión de usuarios
- **Owner Service**: Gestión de propietarios de mascotas
- **Pet Service**: Gestión de mascotas con almacenamiento de imágenes en Google Cloud
- **Alert Service**: Sistema de alertas para mascotas perdidas/encontradas
- **Scan Service**: Procesamiento de escaneo de huellas nasales
- **AI Service**: Servicio de inteligencia artificial para comparación de huellas
- **Gateway Service**: API Gateway para enrutamiento y seguridad

### Frontend (Móvil)
- **React Native con Expo**: Aplicación móvil multiplataforma
- **TypeScript**: Tipado estático para mayor robustez
- **React Navigation**: Navegación entre pantallas
- **React Native Paper**: Componentes de UI modernos
- **Expo Camera**: Captura de imágenes para escaneo

## 🛠️ Tecnologías Utilizadas

### Backend
- **Spring Boot 3.2.0** con Kotlin
- **PostgreSQL 16** como base de datos principal
- **JWT** para autenticación
- **Google Cloud Storage** para almacenamiento de imágenes
- **Docker & Docker Compose** para containerización
- **Maven** para gestión de dependencias

### Frontend
- **React Native 0.72.6** con Expo
- **TypeScript 5.1.3** para tipado estático
- **React Navigation 6** para navegación
- **React Native Paper 5** para UI
- **Axios** para comunicación con APIs
- **AsyncStorage** para almacenamiento local

### IA y Procesamiento
- **FastAPI** (Python) para el servicio de IA
- **OpenCV** para procesamiento de imágenes
- **Machine Learning** para comparación de huellas nasales

## 📁 Estructura del Proyecto

```
PETNOW-DOGS/
├── auth-service/          # Servicio de autenticación
├── owner-service/         # Servicio de propietarios
├── pet-service/           # Servicio de mascotas
├── alert-service/         # Servicio de alertas
├── scan-service/          # Servicio de escaneo
├── ai-service/            # Servicio de IA
├── gateway-service/       # API Gateway
├── frontend/              # Aplicación móvil
├── scripts/               # Scripts de automatización
├── docs/                  # Documentación
├── docker-compose.yml     # Orquestación de servicios
├── docker-compose.dev.yml # Configuración de desarrollo
├── start-project.sh       # Script de inicio
├── dev-setup.sh           # Script de configuración
└── README.md              # Documentación principal
```

## 🚀 Scripts de Automatización

### Scripts Principales
- **`dev-setup.sh`**: Configuración automática del entorno
- **`start-project.sh`**: Inicio completo del proyecto
- **`scripts/monitor.sh`**: Monitoreo de servicios
- **`scripts/backup-db.sh`**: Backup de base de datos
- **`scripts/restore-db.sh`**: Restauración de base de datos

### Configuración de Desarrollo
- **`.vscode/settings.json`**: Configuración de VS Code
- **`.vscode/extensions.json`**: Extensiones recomendadas
- **`.eslintrc.js`**: Linting para TypeScript
- **`.prettierrc`**: Formateo de código
- **`metro.config.js`**: Configuración de Metro bundler

## 🔧 Configuración y Despliegue

### Prerequisitos
- Docker y Docker Compose
- Node.js 18+
- Java 17+ (para desarrollo local)
- Maven (para desarrollo local)

### Inicio Rápido
```bash
# Configuración automática
./dev-setup.sh

# Inicio del proyecto
./start-project.sh
```

### Puertos de Servicios
- **8080**: API Gateway
- **8081**: Auth Service
- **8082**: Owner Service
- **8083**: Pet Service
- **8084**: Alert Service
- **8085**: AI Service
- **8086**: Scan Service
- **5432**: PostgreSQL

## 📊 Características Principales

### Funcionalidades de Usuario
- Registro e inicio de sesión
- Gestión de perfiles de propietarios
- Registro de mascotas con fotos
- Escaneo de huellas nasales
- Creación y gestión de alertas
- Búsqueda de mascotas perdidas

### Funcionalidades Técnicas
- Autenticación JWT segura
- Almacenamiento de imágenes en la nube
- Procesamiento de imágenes con IA
- API RESTful documentada con Swagger
- Base de datos con esquemas separados
- Logging y monitoreo de servicios

## 🔒 Seguridad

- Autenticación JWT con tokens seguros
- Validación de roles (USER/ADMIN)
- Filtros de seguridad en Gateway
- CORS configurado para frontend
- Variables de entorno para configuración sensible

## 🧪 Testing

### Backend
- Tests unitarios con JUnit 5
- Tests de integración
- Tests de seguridad
- Cobertura de código

### Frontend
- Tests de componentes con Jest
- Tests de navegación
- Tests de integración con APIs

## 📈 Monitoreo y Logs

- Health checks para todos los servicios
- Logs centralizados
- Métricas de rendimiento
- Alertas automáticas

## 🚀 Despliegue

### Desarrollo Local
- Docker Compose para orquestación
- Hot reload para desarrollo
- Volúmenes montados para código

### Producción
- Configuración de variables de entorno
- Base de datos persistente
- Almacenamiento en la nube
- Monitoreo y alertas

## 📚 Documentación

- **README.md**: Documentación principal
- **docs/QUICK_START.md**: Guía de inicio rápido
- **frontend/README.md**: Documentación del frontend
- **docs/PROJECT_SUMMARY.md**: Este resumen

## 🤝 Contribución

1. Fork del proyecto
2. Crear rama feature
3. Commit de cambios
4. Push a la rama
5. Pull Request

## 📄 Licencia

MIT License - ver archivo LICENSE para detalles.

---

**PETNOW-DOGS** - Sistema de identificación de perros por huella nasal 🐕 