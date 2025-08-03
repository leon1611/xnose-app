# 🚀 X-NOSE - Guía de Inicio Rápido para Despliegue

## 📋 Resumen

Esta guía te ayudará a desplegar X-NOSE completamente en Google Cloud Platform en menos de 30 minutos.

## ✅ Prerequisitos

1. **Google Cloud CLI** instalado
2. **Docker** instalado y ejecutándose
3. **Node.js** (opcional, para generar APK)
4. **Cuenta de Google Cloud** con facturación habilitada

## 🚀 Despliegue Automático (Recomendado)

### Opción 1: Despliegue Completo con un Comando

```bash
# Navegar al directorio de despliegue
cd gcp-deploy

# Ejecutar despliegue completo
./scripts/deploy-complete.sh
```

Este comando ejecutará automáticamente:
1. ✅ Configuración de Google Cloud
2. ✅ Construcción y subida de imágenes Docker
3. ✅ Despliegue de todos los servicios
4. ✅ Configuración del frontend
5. ✅ Generación del APK

## 🔧 Despliegue Manual (Paso a Paso)

Si prefieres controlar cada paso:

### Paso 1: Configurar Google Cloud
```bash
cd gcp-deploy
./scripts/setup-gcp.sh
```

### Paso 2: Construir y Subir Imágenes
```bash
./scripts/build-and-push.sh
```

### Paso 3: Desplegar Servicios
```bash
./scripts/deploy-services.sh
```

### Paso 4: Configurar Frontend
```bash
./scripts/update-frontend-config.sh
```

### Paso 5: Generar APK
```bash
cd ../frontend
./generate-apk.sh
```

## 📊 Monitoreo

### Verificar Estado de Servicios
```bash
cd gcp-deploy
./scripts/monitor-services.sh
```

### Monitoreo Continuo
```bash
./scripts/monitor-services.sh continuous
```

### Ver Logs de un Servicio
```bash
./scripts/monitor-services.sh logs gateway-service
```

## 🌐 URLs de Producción

Después del despliegue, tendrás acceso a:

- **Gateway**: `https://xnose-gateway-xxxxx-uc.a.run.app`
- **Auth**: `https://xnose-auth-service-xxxxx-uc.a.run.app`
- **Owner**: `https://xnose-owner-service-xxxxx-uc.a.run.app`
- **Pet**: `https://xnose-pet-service-xxxxx-uc.a.run.app`
- **Alert**: `https://xnose-alert-service-xxxxx-uc.a.run.app`
- **AI**: `https://xnose-ai-service-xxxxx-uc.a.run.app`

## 📱 APK

El archivo APK se generará automáticamente y estará disponible en la carpeta de descargas de Expo.

Para regenerar el APK:
```bash
cd frontend
./generate-apk.sh
```

## 💰 Costos

- **Estimado mensual**: $60-95
- **Desglose**:
  - Cloud Run (6 servicios): $30-50/mes
  - Cloud SQL (ya configurado): $25-35/mes
  - Cloud Storage: $5-10/mes

## 🔒 Seguridad

- ✅ Código fuente protegido (solo imágenes Docker)
- ✅ SSL/TLS automático
- ✅ Variables de entorno seguras
- ✅ Base de datos en Google Cloud SQL

## 🆘 Solución de Problemas

### Error: "Permission denied"
```bash
gcloud auth login
gcloud config set project TU_PROJECT_ID
```

### Error: "Docker not running"
Inicia Docker Desktop o el servicio de Docker

### Error: "API not enabled"
Los scripts habilitan automáticamente las APIs necesarias

### Error: "Image not found"
Ejecuta primero: `./scripts/build-and-push.sh`

## 📞 Soporte

Si encuentras problemas:

1. Verifica los logs del script que falló
2. Asegúrate de tener permisos en Google Cloud
3. Verifica que Docker esté ejecutándose
4. Revisa la configuración en `configs/gcp-config.env`

## 🎯 Próximos Pasos

1. **Probar la aplicación** con el APK generado
2. **Configurar dominio personalizado** (opcional)
3. **Configurar alertas de monitoreo**
4. **Configurar backups automáticos**

---

**¡X-NOSE está listo para revolucionar la identificación de mascotas!** 🐕✨ 