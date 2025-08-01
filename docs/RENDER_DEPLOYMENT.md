# 🚀 Despliegue en Render - X-NOSE

## 📋 Resumen

Esta guía te ayudará a desplegar todos los servicios de X-NOSE en Render, conectándolos con tu base de datos de Google Cloud.

## 🏗️ Arquitectura en Render

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Gateway       │    │  Microservicios │
│   (Render)      │───▶│   (Render)      │───▶│  (Render)       │
│   Puerto: 19000 │    │   Puerto: 8080  │    │  Puertos: 8083+ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   Google Cloud  │
                    │   PostgreSQL    │
                    │   (Base de datos)│
                    └─────────────────┘
```

## 🔧 Servicios a Desplegar

### 1. **Gateway Service** (`xnose-gateway`)
- **Puerto**: 8080
- **Tipo**: Web Service
- **Runtime**: Docker
- **Health Check**: `/actuator/health`

### 2. **Auth Service** (`xnose-auth-service`)
- **Puerto**: 8081
- **Tipo**: Web Service
- **Runtime**: Docker
- **Health Check**: `/actuator/health`

### 3. **Owner Service** (`xnose-owner-service`)
- **Puerto**: 8082
- **Tipo**: Web Service
- **Runtime**: Docker
- **Health Check**: `/actuator/health`

### 4. **Pet Service** (`xnose-pet-service`)
- **Puerto**: 8083
- **Tipo**: Web Service
- **Runtime**: Docker
- **Health Check**: `/actuator/health`

### 5. **Alert Service** (`xnose-alert-service`)
- **Puerto**: 8084
- **Tipo**: Web Service
- **Runtime**: Docker
- **Health Check**: `/actuator/health`

### 6. **AI Service** (`xnose-ai-service`)
- **Puerto**: 8000
- **Tipo**: Web Service
- **Runtime**: Docker
- **Health Check**: `/health`

### 7. **Frontend** (`xnose-frontend`)
- **Puerto**: 19000
- **Tipo**: Web Service
- **Runtime**: Docker
- **Health Check**: `/`

## 📝 Pasos para el Despliegue

### Paso 1: Preparar el Repositorio

1. **Subir el código a GitHub**:

```bash
git add .
git commit -m "Add Docker configuration for Render deployment"
git push origin main
```

2. **Verificar que todos los archivos estén presentes**:
       - `render.yaml` (configuración de Render)
    - `gateway-service/Dockerfile`
    - `auth-service/Dockerfile`
    - `owner-service/Dockerfile`
    - `pet-service/Dockerfile`
    - `alert-service/Dockerfile`
    - `ai-service/Dockerfile`
    - `frontend/Dockerfile`
    - Archivos `.dockerignore` en cada servicio

### Paso 2: Configurar Render

1. **Ir a [Render Dashboard](https://dashboard.render.com/)**
2. **Crear un nuevo "Blueprint"**:
   - Click en "New +"
   - Seleccionar "Blueprint"
   - Conectar tu repositorio de GitHub
   - Render detectará automáticamente el `render.yaml`

### Paso 3: Configurar Variables de Entorno

#### Para Gateway Service:

```bash
SPRING_PROFILES_ACTIVE=production
SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/pet_service_db
SPRING_DATASOURCE_USERNAME=pet_user
SPRING_DATASOURCE_PASSWORD=leon1611
AUTH_SERVICE_URL=https://xnose-auth-service.onrender.com
OWNER_SERVICE_URL=https://xnose-owner-service.onrender.com
PET_SERVICE_URL=https://xnose-pet-service.onrender.com
ALERT_SERVICE_URL=https://xnose-alert-service.onrender.com
AI_SERVICE_URL=https://xnose-ai-service.onrender.com
```

#### Para Auth Service:

```bash
SPRING_PROFILES_ACTIVE=production
SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/auth_service_db
SPRING_DATASOURCE_USERNAME=auth_user
SPRING_DATASOURCE_PASSWORD=leon1611
```

#### Para Owner Service:

```bash
SPRING_PROFILES_ACTIVE=production
SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/owner_service_db
SPRING_DATASOURCE_USERNAME=owner_user
SPRING_DATASOURCE_PASSWORD=leon1611
```

#### Para Pet Service:

```bash
SPRING_PROFILES_ACTIVE=production
SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/pet_service_db
SPRING_DATASOURCE_USERNAME=pet_user
SPRING_DATASOURCE_PASSWORD=leon1611
GCS_BUCKET_NAME=petnow-dogs-images-app-biometrico-db
GOOGLE_CLOUD_PROJECT=app-biometrico-db
AI_SERVICE_URL=https://xnose-ai-service.onrender.com
```

#### Para Alert Service:

```bash
SPRING_PROFILES_ACTIVE=production
SPRING_DATASOURCE_URL=jdbc:postgresql://34.66.242.149:5432/alert_service_db
SPRING_DATASOURCE_USERNAME=alert_user
SPRING_DATASOURCE_PASSWORD=leon1611
```

#### Para AI Service:

```bash
PYTHONUNBUFFERED=1
LOG_LEVEL=INFO
SIMILARITY_THRESHOLD=0.80
CONFIDENCE_BOOST=0.1
```

#### Para Frontend:

```bash
EXPO_PUBLIC_API_URL=https://xnose-gateway.onrender.com
EXPO_PUBLIC_AI_SERVICE_URL=https://xnose-ai-service.onrender.com
EXPO_PUBLIC_GCS_BUCKET_URL=https://storage.googleapis.com/petnow-dogs-images-app-biometrico-db
```

### Paso 4: Configurar Google Cloud

1. **Verificar la base de datos**:

   - IP: `34.66.242.149`
   - Puerto: `5432`
   - Base de datos: `pet_service_db`
   - Usuario: `pet_user`
   - Contraseña: `leon1611`

2. **Configurar firewall**:

   - Agregar las IPs de Render a la lista blanca
   - Render IPs: `0.0.0.0/0` (temporalmente para pruebas)

3. **Verificar Google Cloud Storage**:
   - Bucket: `petnow-dogs-images-app-biometrico-db`
   - Proyecto: `app-biometrico-db`

## 🔄 URLs de los Servicios

Una vez desplegados, los servicios estarán disponibles en:

- **Gateway**: `https://xnose-gateway.onrender.com`
- **Auth Service**: `https://xnose-auth-service.onrender.com`
- **Owner Service**: `https://xnose-owner-service.onrender.com`
- **Pet Service**: `https://xnose-pet-service.onrender.com`
- **Alert Service**: `https://xnose-alert-service.onrender.com`
- **AI Service**: `https://xnose-ai-service.onrender.com`
- **Frontend**: `https://xnose-frontend.onrender.com`

## 🧪 Pruebas Post-Despliegue

### 1. Verificar Health Checks

```bash
# Gateway
curl https://xnose-gateway.onrender.com/actuator/health

# Auth Service
curl https://xnose-auth-service.onrender.com/actuator/health

# Owner Service
curl https://xnose-owner-service.onrender.com/actuator/health

# Pet Service
curl https://xnose-pet-service.onrender.com/actuator/health

# Alert Service
curl https://xnose-alert-service.onrender.com/actuator/health

# AI Service
curl https://xnose-ai-service.onrender.com/health
```

### 2. Probar Endpoints

```bash
# Gateway - Listar rutas
curl https://xnose-gateway.onrender.com/actuator/gateway/routes

# AI Service - Información del modelo
curl https://xnose-ai-service.onrender.com/model-stats
```

### 3. Probar Frontend

1. Abrir `https://xnose-frontend.onrender.com`
2. Verificar que se conecte correctamente al Gateway
3. Probar funcionalidades básicas

## 🔧 Configuraciones Específicas

### Configuración de CORS

Los servicios están configurados para permitir:

- `https://*.onrender.com`
- `https://*.vercel.app`
- `http://localhost:19000` (desarrollo)

### Configuración de Timeouts

- **Gateway**: 10s connect, 60s response
- **Pet Service**: 30s para uploads de imágenes
- **AI Service**: Sin límites específicos

### Configuración de Logs

- **Nivel**: INFO en producción
- **Formato**: Timestamp + mensaje
- **Archivos**: Solo en desarrollo, logs a stdout en producción

## 🚨 Solución de Problemas

### Problemas Comunes

#### 1. **Error de conexión a base de datos**

```bash
# Verificar variables de entorno
echo $SPRING_DATASOURCE_URL
echo $SPRING_DATASOURCE_USERNAME
echo $SPRING_DATASOURCE_PASSWORD

# Verificar conectividad desde Render
# Usar pg_isready o similar
```

#### 2. **Error de CORS**

```bash
# Verificar configuración en application-prod.yml
# Asegurar que los orígenes estén correctamente configurados
```

#### 3. **Error de memoria en AI Service**

```bash
# Aumentar memoria en Render
# Configurar variables de entorno para optimizar TensorFlow
export TF_FORCE_GPU_ALLOW_GROWTH=true
```

#### 4. **Error de build en Docker**

```bash
# Verificar Dockerfiles
# Verificar .dockerignore
# Verificar dependencias
```

### Logs de Debug

```bash
# Ver logs en Render Dashboard
# O usar curl para health checks
curl -v https://xnose-gateway.onrender.com/actuator/health
```

## 📊 Monitoreo

### Métricas Disponibles

- **Health Checks**: Automáticos en Render
- **Logs**: Disponibles en Render Dashboard
- **Métricas**: `/actuator/metrics` en servicios Spring Boot

### Alertas

Configurar alertas en Render para:

- Health check failures
- Build failures
- Deployment failures

## 🔮 Optimizaciones Futuras

### 1. **Base de Datos**

- Migrar a Cloud SQL en Google Cloud
- Configurar replicas de lectura
- Implementar connection pooling

### 2. **CDN**

- Configurar Cloud CDN para imágenes
- Optimizar carga de assets del frontend

### 3. **Load Balancing**

- Configurar múltiples instancias
- Implementar auto-scaling

### 4. **SSL/TLS**

- Configurar certificados personalizados
- Implementar HSTS

## 📝 Notas Importantes

1. **Variables de Entorno**: Nunca committear credenciales
2. **Base de Datos**: Asegurar que esté accesible desde Render
3. **CORS**: Configurar correctamente para producción
4. **Logs**: Revisar regularmente para detectar problemas
5. **Backups**: Configurar backups automáticos de la base de datos

## 🎯 Checklist de Despliegue

- [ ] Código subido a GitHub
- [ ] `render.yaml` configurado
- [ ] Dockerfiles creados
- [ ] Variables de entorno configuradas
- [ ] Base de datos accesible
- [ ] Health checks funcionando
- [ ] CORS configurado
- [ ] Frontend conectado
- [ ] Pruebas realizadas
- [ ] Monitoreo configurado
