# Variables de Entorno para Render - XNOSE

Este documento explica todas las variables de entorno que necesitas configurar en Render para desplegar la aplicación XNOSE.

## Variables de Base de Datos (Comunes para todos los servicios Spring Boot)

Estas variables se configuran automáticamente cuando conectas la base de datos PostgreSQL de Render:

- `SPRING_DATASOURCE_URL`: URL de conexión a la base de datos PostgreSQL
- `SPRING_DATASOURCE_USERNAME`: Usuario de la base de datos
- `SPRING_DATASOURCE_PASSWORD`: Contraseña de la base de datos

## Variables de Seguridad (JWT)

### JWT_SECRET
**Descripción**: Clave secreta para firmar y verificar tokens JWT
**Valor recomendado**: Una cadena larga y segura (mínimo 32 caracteres)
**Ejemplo**: `xnose_jwt_secret_key_2024_very_long_and_secure_for_hmac_sha256_algorithm`

### JWT_EXPIRATION
**Descripción**: Tiempo de expiración de los tokens JWT en milisegundos
**Valor**: `86400000` (24 horas)

## Variables de Google Cloud Storage

### GCS_BUCKET_NAME
**Descripción**: Nombre del bucket de Google Cloud Storage para almacenar imágenes
**Ejemplo**: `xnose-images-bucket`

### GOOGLE_CLOUD_PROJECT
**Descripción**: ID del proyecto de Google Cloud
**Ejemplo**: `xnose-project-123456`

### GOOGLE_APPLICATION_CREDENTIALS
**Descripción**: Contenido del archivo JSON de credenciales de servicio de Google Cloud
**Nota**: Debes copiar todo el contenido del archivo JSON de credenciales de servicio

## Variables del Frontend

### EXPO_PUBLIC_GCS_BUCKET_URL
**Descripción**: URL pública del bucket de Google Cloud Storage
**Formato**: `https://storage.googleapis.com/[BUCKET_NAME]`
**Ejemplo**: `https://storage.googleapis.com/xnose-images-bucket`

## Variables del AI Service

### SIMILARITY_THRESHOLD
**Descripción**: Umbral de similitud para la comparación de huellas nasales
**Valor**: `0.80`

### CONFIDENCE_BOOST
**Descripción**: Factor de incremento de confianza para las predicciones
**Valor**: `0.1`

### EMBEDDINGS_FILE
**Descripción**: Nombre del archivo que contiene los embeddings de las huellas nasales
**Valor**: `nose_print_embeddings.json`

### AUDIT_LOG_FILE
**Descripción**: Nombre del archivo de log para auditoría
**Valor**: `requests.log`

### CORS_ORIGINS
**Descripción**: Orígenes permitidos para CORS
**Valor**: `https://*.onrender.com,https://*.vercel.app,http://localhost:19000,http://localhost:3000`

## Variables de Logging

### LOG_LEVEL
**Descripción**: Nivel de logging para todos los servicios
**Valor**: `INFO`

## Configuración por Servicio

### Gateway Service
- Todas las variables de base de datos
- `JWT_SECRET`
- `JWT_EXPIRATION`
- `LOG_LEVEL`
- URLs de los otros servicios (configuradas automáticamente)

### Auth Service
- Todas las variables de base de datos
- `JWT_SECRET`
- `JWT_EXPIRATION`
- `LOG_LEVEL`

### Owner Service
- Todas las variables de base de datos
- `JWT_SECRET`
- `JWT_EXPIRATION`
- `LOG_LEVEL`

### Pet Service
- Todas las variables de base de datos
- `JWT_SECRET`
- `JWT_EXPIRATION`
- `LOG_LEVEL`
- `GCS_BUCKET_NAME`
- `GOOGLE_CLOUD_PROJECT`
- `GOOGLE_APPLICATION_CREDENTIALS`
- `AI_SERVICE_ENABLED` (valor: `true`)
- `GCS_ENABLED` (valor: `true`)

### Alert Service
- Todas las variables de base de datos
- `JWT_SECRET`
- `JWT_EXPIRATION`
- `LOG_LEVEL`

### AI Service
- `HOST` (valor: `0.0.0.0`)
- `PORT` (valor: `8000`)
- `LOG_LEVEL`
- `SIMILARITY_THRESHOLD`
- `CONFIDENCE_BOOST`
- `EMBEDDINGS_FILE`
- `AUDIT_LOG_FILE`
- `GCS_BUCKET_NAME`
- `GOOGLE_CLOUD_PROJECT`
- `GOOGLE_APPLICATION_CREDENTIALS`
- `CORS_ORIGINS`

### Frontend
- `EXPO_PUBLIC_GCS_BUCKET_URL`
- `NODE_ENV` (valor: `production`)

## Pasos para Configurar las Variables en Render

1. **Crear la base de datos PostgreSQL**:
   - Ve a la sección "Databases" en Render
   - Crea una nueva base de datos PostgreSQL
   - Anota las credenciales de conexión

2. **Configurar variables sensibles**:
   - Para cada servicio, ve a la sección "Environment"
   - Configura las variables marcadas como `sync: false`
   - Estas son las variables que contienen información sensible

3. **Variables que debes configurar manualmente**:
   - `JWT_SECRET`: Genera una clave segura
   - `GCS_BUCKET_NAME`: Nombre de tu bucket de Google Cloud
   - `GOOGLE_CLOUD_PROJECT`: ID de tu proyecto de Google Cloud
   - `GOOGLE_APPLICATION_CREDENTIALS`: Contenido del archivo JSON de credenciales
   - `EXPO_PUBLIC_GCS_BUCKET_URL`: URL pública de tu bucket

4. **Variables que se configuran automáticamente**:
   - `SPRING_DATASOURCE_URL`
   - `SPRING_DATASOURCE_USERNAME`
   - `SPRING_DATASOURCE_PASSWORD`
   - URLs de los servicios (se configuran automáticamente en el render.yaml)

## Ejemplo de Configuración de Variables Sensibles

```bash
# JWT Secret (genera una clave segura)
JWT_SECRET=xnose_jwt_secret_key_2024_very_long_and_secure_for_hmac_sha256_algorithm

# Google Cloud Storage
GCS_BUCKET_NAME=xnose-images-bucket
GOOGLE_CLOUD_PROJECT=xnose-project-123456
GOOGLE_APPLICATION_CREDENTIALS={"type":"service_account","project_id":"xnose-project-123456",...}

# Frontend
EXPO_PUBLIC_GCS_BUCKET_URL=https://storage.googleapis.com/xnose-images-bucket
```

## Notas Importantes

1. **Seguridad**: Nunca commits las variables sensibles en el código
2. **Google Cloud**: Asegúrate de tener configurado Google Cloud Storage y las credenciales de servicio
3. **Base de datos**: La base de datos se crea automáticamente con el render.yaml
4. **URLs**: Las URLs de los servicios se configuran automáticamente basándose en los nombres de los servicios
5. **CORS**: Los orígenes CORS están configurados para permitir acceso desde Render y desarrollo local 