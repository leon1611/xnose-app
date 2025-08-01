# 🚀 Guía de Despliegue en Render con Docker

Esta guía te ayudará a desplegar X-NOSE en Render usando contenedores Docker optimizados.

## 📋 Prerequisitos

- Cuenta en [Render](https://render.com)
- Cuenta en [Google Cloud Platform](https://cloud.google.com)
- Repositorio en GitHub
- Google Cloud SDK instalado (opcional, para configuración automática)

## 🔧 Configuración de Google Cloud

### Opción 1: Configuración Automática

```bash
# Ejecutar script de configuración
chmod +x scripts/setup-google-cloud.sh
./scripts/setup-google-cloud.sh
```

### Opción 2: Configuración Manual

1. **Crear proyecto en Google Cloud**
   - Ve a [Google Cloud Console](https://console.cloud.google.com)
   - Crea un nuevo proyecto o selecciona uno existente

2. **Habilitar APIs necesarias**
   ```bash
   gcloud services enable storage.googleapis.com
   gcloud services enable iam.googleapis.com
   ```

3. **Crear bucket de almacenamiento**
   ```bash
   gsutil mb -l us-central1 gs://xnose-pet-images
   gsutil iam ch allUsers:objectViewer gs://xnose-pet-images
   ```

4. **Crear Service Account**
   ```bash
   gcloud iam service-accounts create xnose-service-account \
       --display-name="X-NOSE Service Account"
   
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
       --member="serviceAccount:xnose-service-account@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/storage.objectAdmin"
   
   gcloud iam service-accounts keys create service-account-key.json \
       --iam-account=xnose-service-account@YOUR_PROJECT_ID.iam.gserviceaccount.com
   ```

## 🐳 Configuración de Docker

### Estructura de Dockerfiles

Cada servicio tiene su propio Dockerfile optimizado:

- **Multi-stage builds** para reducir el tamaño de las imágenes
- **Usuarios no-root** para seguridad
- **Health checks** para monitoreo
- **Optimizaciones de memoria** para Java

### Construcción Local

```bash
# Construir todas las imágenes
docker-compose build

# Ejecutar localmente
docker-compose up -d

# Ver logs
docker-compose logs -f
```

## 🌐 Despliegue en Render

### 1. Preparar el Repositorio

```bash
# Asegurar que todos los cambios estén commiteados
git add .
git commit -m "Deploy: Configuración Docker para Render"
git push origin main
```

### 2. Configurar Servicios en Render

#### Base de Datos PostgreSQL

1. Ve a [Render Dashboard](https://dashboard.render.com)
2. Crea un nuevo **PostgreSQL**
3. Configura:
   - **Name**: `xnose-database`
   - **Database**: `xnose_db`
   - **User**: `xnose_user`
   - **Plan**: Free (o el que prefieras)

#### Servicios Web

Para cada servicio, crea un nuevo **Web Service**:

1. **Conecta tu repositorio de GitHub**
2. **Configura el servicio**:
   - **Name**: `xnose-[service-name]`
   - **Runtime**: `Docker`
   - **Dockerfile Path**: `./[service-name]/Dockerfile`
   - **Docker Context**: `./[service-name]`

### 3. Variables de Entorno

Configura estas variables en cada servicio:

#### Variables Comunes (todos los servicios)

```bash
SPRING_PROFILES_ACTIVE=production
JWT_SECRET=tu-super-secreto-jwt-muy-largo-y-seguro
JWT_EXPIRATION=86400000
LOG_LEVEL=INFO
```

#### Base de Datos (todos los servicios Spring Boot)

```bash
SPRING_DATASOURCE_URL=jdbc:postgresql://tu-render-postgres-url:5432/xnose_db
SPRING_DATASOURCE_USERNAME=xnose_user
SPRING_DATASOURCE_PASSWORD=tu-password-de-render
```

#### Google Cloud (Pet Service y AI Service)

```bash
GOOGLE_CLOUD_PROJECT=tu-proyecto-id
GCS_BUCKET_NAME=xnose-pet-images
GOOGLE_APPLICATION_CREDENTIALS=/app/credentials/service-account-key.json
```

**⚠️ IMPORTANTE**: Para `GOOGLE_APPLICATION_CREDENTIALS`, copia el contenido completo del archivo JSON de la service account.

#### URLs de Servicios (Gateway Service)

```bash
AUTH_SERVICE_URL=https://xnose-auth-service.onrender.com
OWNER_SERVICE_URL=https://xnose-owner-service.onrender.com
PET_SERVICE_URL=https://xnose-pet-service.onrender.com
ALERT_SERVICE_URL=https://xnose-alert-service.onrender.com
AI_SERVICE_URL=https://xnose-ai-service.onrender.com
```

#### Frontend

```bash
EXPO_PUBLIC_API_URL=https://xnose-gateway.onrender.com
EXPO_PUBLIC_AI_SERVICE_URL=https://xnose-ai-service.onrender.com
EXPO_PUBLIC_GCS_BUCKET_URL=https://storage.googleapis.com/xnose-pet-images
NODE_ENV=production
```

### 4. Orden de Despliegue

Despliega los servicios en este orden:

1. **Base de datos PostgreSQL**
2. **AI Service** (puerto 8000)
3. **Auth Service** (puerto 8081)
4. **Owner Service** (puerto 8082)
5. **Pet Service** (puerto 8083)
6. **Alert Service** (puerto 8084)
7. **Gateway Service** (puerto 8080)
8. **Frontend** (puerto 80)

### 5. Configuración de Health Checks

Cada servicio tiene health checks configurados:

- **Spring Boot Services**: `/actuator/health`
- **AI Service**: `/health`
- **Frontend**: `/health`

## 🔍 Verificación del Despliegue

### Verificación Automática

```bash
# Ejecutar script de verificación
chmod +x scripts/verify-deployment.sh
./scripts/verify-deployment.sh
```

### Verificación Manual

1. **Verificar cada servicio**:
   - Gateway: `https://xnose-gateway.onrender.com/actuator/health`
   - Auth: `https://xnose-auth-service.onrender.com/actuator/health`
   - Owner: `https://xnose-owner-service.onrender.com/actuator/health`
   - Pet: `https://xnose-pet-service.onrender.com/actuator/health`
   - Alert: `https://xnose-alert-service.onrender.com/actuator/health`
   - AI: `https://xnose-ai-service.onrender.com/health`
   - Frontend: `https://xnose-frontend.onrender.com/health`

2. **Probar funcionalidad**:
   - Acceder al frontend
   - Registrar un usuario
   - Registrar una mascota
   - Probar el escaneo

## 🛠️ Solución de Problemas

### Problemas Comunes

#### 1. Servicios no inician

**Síntomas**: Error 503 o timeout en health checks

**Solución**:
- Verificar variables de entorno
- Revisar logs en Render Dashboard
- Verificar conectividad de base de datos

#### 2. Error de Google Cloud

**Síntomas**: Error 500 en Pet Service o AI Service

**Solución**:
- Verificar `GOOGLE_APPLICATION_CREDENTIALS`
- Confirmar que el bucket existe
- Verificar permisos del service account

#### 3. Problemas de CORS

**Síntomas**: Error en frontend al hacer peticiones

**Solución**:
- Verificar `CORS_ORIGINS` en AI Service
- Confirmar URLs en frontend

#### 4. Base de datos no conecta

**Síntomas**: Error de conexión en servicios Spring Boot

**Solución**:
- Verificar `SPRING_DATASOURCE_URL`
- Confirmar credenciales
- Verificar que la base de datos esté activa

### Logs y Debugging

```bash
# Ver logs en Render Dashboard
# 1. Ve al servicio con problemas
# 2. Pestaña "Logs"
# 3. Busca errores específicos

# Comandos útiles para debugging
curl -v https://tu-servicio.onrender.com/actuator/health
```

## 📊 Monitoreo

### Métricas a Monitorear

- **Uptime**: Disponibilidad de servicios
- **Response Time**: Tiempo de respuesta
- **Error Rate**: Tasa de errores
- **Memory Usage**: Uso de memoria
- **Database Connections**: Conexiones a BD

### Alertas Recomendadas

- Servicio down por más de 5 minutos
- Error rate > 5%
- Response time > 10 segundos
- Memory usage > 80%

## 🔄 Actualizaciones

### Despliegue de Nuevas Versiones

```bash
# 1. Hacer cambios en el código
# 2. Commit y push
git add .
git commit -m "Update: descripción de cambios"
git push origin main

# 3. Render detectará automáticamente los cambios
# 4. Desplegará automáticamente si auto-deploy está habilitado
```

### Rollback

1. Ve a Render Dashboard
2. Selecciona el servicio
3. Ve a "Deploys"
4. Selecciona una versión anterior
5. Haz "Redeploy"

## 💰 Optimización de Costos

### Render Free Tier

- **Web Services**: 750 horas/mes
- **PostgreSQL**: 90 días gratis
- **Bandwidth**: 100GB/mes

### Recomendaciones

1. **Usar Free Tier** para desarrollo/pruebas
2. **Upgrade gradual** según necesidades
3. **Monitorear uso** regularmente
4. **Optimizar imágenes** para reducir transferencia

## 📞 Soporte

### Recursos Útiles

- [Render Documentation](https://render.com/docs)
- [Google Cloud Documentation](https://cloud.google.com/docs)
- [Docker Documentation](https://docs.docker.com)

### Contacto

Para problemas específicos del proyecto:
- Revisar logs en Render
- Consultar documentación del proyecto
- Crear issue en el repositorio

---

**¡Tu aplicación X-NOSE está lista para producción! 🎉** 