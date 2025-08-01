# 🗄️ Configuración Automática de Google Cloud SQL

Esta guía te ayudará a configurar automáticamente las bases de datos en Google Cloud SQL para el proyecto PetNow-Dogs.

## 📋 Prerrequisitos

### 1. **Cuenta de Google Cloud Platform**

- [Crear cuenta GCP](https://cloud.google.com/)
- [Habilitar facturación](https://console.cloud.google.com/billing)
- [Crear proyecto](https://console.cloud.google.com/projectcreate)

### 2. **Google Cloud CLI**

```bash
# Instalar Google Cloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Autenticarse
gcloud auth login
gcloud config set project TU_PROJECT_ID
```

### 3. **Terraform (Opcional)**

```bash
# Instalar Terraform
brew install terraform  # macOS
# o descargar desde https://terraform.io/downloads
```

## 🚀 Opción 1: Script Bash (Recomendado para desarrollo)

### Paso 1: Configurar el script

```bash
cd scripts
chmod +x setup-gcp-databases.sh
```

### Paso 2: Ejecutar el script

```bash
./setup-gcp-databases.sh
```

### Paso 3: Seguir las instrucciones

El script te pedirá:

- Contraseña para usuario root
- Contraseña base para usuarios de servicios

### Paso 4: Configurar microservicios

El script generará un archivo `gcp-database-config.env` con todas las configuraciones.

## 🏗️ Opción 2: Terraform (Recomendado para producción)

### Paso 1: Configurar variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tu PROJECT_ID
```

### Paso 2: Inicializar Terraform

```bash
terraform init
```

### Paso 3: Planificar cambios

```bash
terraform plan
```

### Paso 4: Aplicar configuración

```bash
terraform apply
```

### Paso 5: Obtener outputs

```bash
terraform output
```

## 📊 Recursos Creados

### **Bases de Datos**

- `auth_service_db` - Autenticación y usuarios
- `owner_service_db` - Propietarios de mascotas
- `pet_service_db` - Mascotas e imágenes
- `alert_service_db` - Alertas de mascotas perdidas/encontradas
- `scan_service_db` - Escaneos de huella nasal

### **Usuarios**

- `auth_user` - Usuario para auth-service
- `owner_user` - Usuario para owner-service
- `pet_user` - Usuario para pet-service
- `alert_user` - Usuario para alert-service
- `scan_user` - Usuario para scan-service

### **Infraestructura Adicional (Terraform)**

- **Cloud Storage Bucket** - Para almacenar imágenes
- **Cloud Run Service** - Para el AI Service
- **IAM Policies** - Permisos de acceso

## 🔧 Configuración de Microservicios

### 1. **Actualizar application.yml**

Para cada microservicio, actualiza el archivo `application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://${GCP_SQL_IP}:5432/${SERVICE_DB_NAME}
    username: ${SERVICE_DB_USER}
    password: ${SERVICE_PASSWORD}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: update
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
```

### 2. **Variables de Entorno**

Crea un archivo `.env` en cada microservicio:

```bash
# Auth Service
AUTH_DB_USER=auth_user
AUTH_DB_NAME=auth_service_db
AUTH_DB_PASSWORD=tu_contraseña

# Owner Service
OWNER_DB_USER=owner_user
OWNER_DB_NAME=owner_service_db
OWNER_DB_PASSWORD=tu_contraseña

# Pet Service
PET_DB_USER=pet_user
PET_DB_NAME=pet_service_db
PET_DB_PASSWORD=tu_contraseña
GCS_BUCKET_NAME=petnow-dogs-images-tu-project-id

# Alert Service
ALERT_DB_USER=alert_user
ALERT_DB_NAME=alert_service_db
ALERT_DB_PASSWORD=tu_contraseña

# Scan Service
SCAN_DB_USER=scan_user
SCAN_DB_NAME=scan_service_db
SCAN_DB_PASSWORD=tu_contraseña
AI_SERVICE_URL=https://petnow-ai-service-xxx.run.app
```

## 🔐 Seguridad

### **Firewall**

- Solo tu IP está autorizada para acceder a la base de datos
- SSL está habilitado por defecto
- Contraseñas seguras generadas automáticamente

### **Backups**

- Backups automáticos diarios a las 2:00 AM
- Retención de 7 días
- Point-in-time recovery habilitado

### **Mantenimiento**

- Ventana de mantenimiento: Domingos 3:00 AM
- Actualizaciones automáticas de seguridad

## 💰 Costos Estimados

### **Desarrollo (db-f1-micro)**

- **Cloud SQL**: ~$7-15/mes
- **Cloud Storage**: ~$0.02/GB/mes
- **Cloud Run**: ~$0.40/mes (si usas Terraform)

### **Producción (db-n1-standard-2)**

- **Cloud SQL**: ~$50-100/mes
- **Cloud Storage**: ~$0.02/GB/mes
- **Cloud Run**: ~$5-20/mes

## 🐛 Solución de Problemas

### **Error: "Permission denied"**

```bash
# Verificar permisos
gcloud auth list
gcloud config get-value project

# Asignar roles necesarios
gcloud projects add-iam-policy-binding TU_PROJECT_ID \
    --member="user:tu-email@gmail.com" \
    --role="roles/cloudsql.admin"
```

### **Error: "API not enabled"**

```bash
# Habilitar APIs manualmente
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

### **Error: "Connection timeout"**

- Verificar reglas de firewall
- Confirmar IP autorizada
- Verificar que la instancia esté ejecutándose

### **Error: "Invalid credentials"**

```bash
# Regenerar credenciales
gcloud auth application-default login
```

## 📞 Soporte

### **Comandos Útiles**

```bash
# Ver instancias de Cloud SQL
gcloud sql instances list

# Ver bases de datos
gcloud sql databases list --instance=petnow-dogs-db

# Ver usuarios
gcloud sql users list --instance=petnow-dogs-db

# Conectar a la base de datos
gcloud sql connect petnow-dogs-db --user=root
```

### **Logs y Monitoreo**

```bash
# Ver logs de la instancia
gcloud sql instances describe petnow-dogs-db

# Monitorear métricas
gcloud monitoring metrics list
```

## 🔄 Actualización y Mantenimiento

### **Actualizar contraseñas**

```bash
# Cambiar contraseña de usuario
gcloud sql users set-password USERNAME \
    --instance=petnow-dogs-db \
    --password=NUEVA_CONTRASEÑA
```

### **Escalar instancia**

```bash
# Cambiar tier de la instancia
gcloud sql instances patch petnow-dogs-db \
    --tier=db-n1-standard-2
```

### **Backup manual**

```bash
# Crear backup manual
gcloud sql backups create \
    --instance=petnow-dogs-db \
    --description="Backup manual"
```

---

**¡Tu infraestructura de Google Cloud está lista para PetNow-Dogs!** 🎉
