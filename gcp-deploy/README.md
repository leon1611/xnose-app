# 🚀 X-NOSE - Despliegue en Google Cloud

## 📋 Resumen del Despliegue

Este directorio contiene todos los archivos necesarios para desplegar X-NOSE en Google Cloud Platform usando Docker y Cloud Run.

## 🏗️ Arquitectura de Despliegue

### Servicios Desplegados:
- **Gateway Service** - API Gateway (Puerto 8080)
- **Auth Service** - Autenticación JWT (Puerto 8081)
- **Owner Service** - Gestión de propietarios (Puerto 8082)
- **Pet Service** - Gestión de mascotas (Puerto 8083)
- **Alert Service** - Sistema de alertas (Puerto 8084)
- **AI Service** - Procesamiento de IA (Puerto 8000)

### Infraestructura:
- **Google Cloud Run** - Servicios containerizados
- **Google Cloud SQL** - Base de datos PostgreSQL
- **Google Cloud Storage** - Almacenamiento de imágenes
- **Google Container Registry** - Imágenes Docker

## 🚀 Inicio Rápido

```bash
# 1. Configurar Google Cloud
./scripts/setup-gcp.sh

# 2. Construir y subir imágenes
./scripts/build-and-push.sh

# 3. Desplegar servicios
./scripts/deploy-services.sh

# 4. Configurar dominio
./scripts/setup-domain.sh
```

## 📁 Estructura de Archivos

```
gcp-deploy/
├── README.md                    # Este archivo
├── scripts/                     # Scripts de automatización
│   ├── setup-gcp.sh            # Configuración inicial de GCP
│   ├── build-and-push.sh       # Construir y subir imágenes
│   ├── deploy-services.sh      # Desplegar servicios
│   ├── setup-domain.sh         # Configurar dominio
│   └── monitor-services.sh     # Monitorear servicios
├── configs/                     # Configuraciones
│   ├── cloud-run/              # Configuraciones de Cloud Run
│   └── terraform/              # Infraestructura como código
└── dockerfiles/                # Dockerfiles optimizados
```

## 💰 Costos Estimados

- **Cloud Run**: ~$50-80/mes
- **Cloud SQL**: ~$25-35/mes
- **Cloud Storage**: ~$5-10/mes
- **Total**: ~$80-125/mes

## 🔒 Seguridad

- Código fuente protegido (solo imágenes Docker)
- Variables de entorno seguras
- SSL/TLS automático
- IAM configurado

## 📱 APK Generation

Una vez desplegado, el APK apuntará a las URLs de Cloud Run:
- Gateway: `https://xnose-gateway-xxxxx-uc.a.run.app`
- AI Service: `https://xnose-ai-service-xxxxx-uc.a.run.app`

---

**X-NOSE** - Sistema de identificación de perros por huella nasal 🐕 