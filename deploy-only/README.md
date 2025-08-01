# 🚀 X-NOSE - Archivos de Despliegue

Este directorio contiene **SOLO** los archivos necesarios para desplegar X-NOSE en Render.

## 📁 Estructura

```
deploy-only/
├── render.yaml              # Configuración principal de Render
├── dockerfiles/             # Dockerfiles para cada servicio
│   ├── gateway-service/
│   ├── auth-service/
│   ├── owner-service/
│   ├── pet-service/
│   ├── alert-service/
│   ├── ai-service/
│   └── frontend/
├── configs/                 # Configuraciones de producción
│   ├── gateway-service/
│   ├── auth-service/
│   ├── owner-service/
│   ├── pet-service/
│   ├── alert-service/
│   └── frontend/
└── scripts/                 # Scripts de despliegue
    └── deploy-render.sh
```

## 🎯 Propósito

- **NO incluye código fuente** del proyecto
- **Solo archivos de configuración** para Render
- **Dockerfiles optimizados** para producción
- **Variables de entorno** preconfiguradas

## 🚀 Uso

1. Subir este directorio a un repositorio separado
2. Conectar a Render como Blueprint
3. Configurar variables de entorno
4. Desplegar automáticamente

## 📝 Nota

Este es un repositorio de **solo despliegue**, no contiene el código fuente de X-NOSE. 