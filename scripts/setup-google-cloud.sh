#!/bin/bash

echo "🔧 CONFIGURACIÓN DE GOOGLE CLOUD STORAGE PARA X-NOSE"
echo "=================================================="
echo ""

# Verificar si gcloud está instalado
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud SDK no está instalado."
    echo "📥 Instala Google Cloud SDK desde: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Verificar si el usuario está autenticado
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "🔐 Iniciando autenticación con Google Cloud..."
    gcloud auth login
fi

# Solicitar información del proyecto
echo "📋 Configuración del proyecto:"
read -p "Ingresa el ID del proyecto de Google Cloud: " PROJECT_ID
read -p "Ingresa el nombre del bucket para imágenes (ej: xnose-pet-images): " BUCKET_NAME
read -p "Ingresa la región para el bucket (ej: us-central1): " REGION

# Configurar proyecto
echo "⚙️ Configurando proyecto: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Crear bucket si no existe
echo "🪣 Creando bucket: $BUCKET_NAME"
if ! gsutil ls -b gs://$BUCKET_NAME &> /dev/null; then
    gsutil mb -l $REGION gs://$BUCKET_NAME
    echo "✅ Bucket creado exitosamente"
else
    echo "ℹ️ El bucket ya existe"
fi

# Configurar permisos del bucket
echo "🔒 Configurando permisos del bucket..."
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

# Crear service account para la aplicación
echo "👤 Creando service account..."
SA_NAME="xnose-service-account"
SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

if ! gcloud iam service-accounts describe $SA_EMAIL &> /dev/null; then
    gcloud iam service-accounts create $SA_NAME \
        --display-name="X-NOSE Service Account" \
        --description="Service account para X-NOSE application"
    echo "✅ Service account creado"
else
    echo "ℹ️ Service account ya existe"
fi

# Asignar roles necesarios
echo "🔑 Asignando roles al service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/storage.objectAdmin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/storage.objectViewer"

# Crear y descargar la clave del service account
echo "🔐 Creando clave del service account..."
KEY_FILE="service-account-key.json"
gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SA_EMAIL

# Mover la clave a la ubicación correcta
mkdir -p pet-service/credentials
mv $KEY_FILE pet-service/credentials/

echo ""
echo "✅ CONFIGURACIÓN COMPLETADA"
echo "=========================="
echo ""
echo "📋 Información de configuración:"
echo "   Proyecto ID: $PROJECT_ID"
echo "   Bucket: gs://$BUCKET_NAME"
echo "   Región: $REGION"
echo "   Service Account: $SA_EMAIL"
echo "   Clave guardada en: pet-service/credentials/$KEY_FILE"
echo ""
echo "🔧 Variables de entorno para Render:"
echo "   GOOGLE_CLOUD_PROJECT=$PROJECT_ID"
echo "   GCS_BUCKET_NAME=$BUCKET_NAME"
echo "   GOOGLE_APPLICATION_CREDENTIALS=/app/credentials/$KEY_FILE"
echo ""
echo "⚠️ IMPORTANTE:"
echo "   1. Agrega pet-service/credentials/ al .gitignore"
echo "   2. Configura las variables de entorno en Render"
echo "   3. Sube la clave del service account a Render como variable de entorno"
echo ""
echo "🚀 Para continuar con el despliegue:"
echo "   1. Sube el código a GitHub"
echo "   2. Conecta el repositorio a Render"
echo "   3. Configura las variables de entorno en Render"
echo "   4. Despliega los servicios" 