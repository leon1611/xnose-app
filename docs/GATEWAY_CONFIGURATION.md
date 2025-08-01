# 🚪 Configuración del Gateway Service

## 📋 Resumen

El **Gateway Service** actúa como punto de entrada único para toda la aplicación PETNOW-DOGS, implementando un patrón de **API Gateway** que enruta las peticiones a los microservicios correspondientes.

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Gateway       │    │  Microservicios │
│   (React Native)│───▶│   Service       │───▶│  (Spring Boot)  │
│   Puerto: 19000 │    │   Puerto: 8080  │    │  Puertos: 8081+ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Configuración Actual

### Puerto y Dirección

```yaml
server:
  port: 8080
  address: 0.0.0.0 # Escucha en todas las interfaces
```

### Rutas Configuradas

| Ruta Gateway | Servicio Destino | Puerto | Descripción                  |
| ------------ | ---------------- | ------ | ---------------------------- |
| `/auth/**`   | Auth Service     | 8081   | Autenticación y autorización |
| `/owners/**` | Owner Service    | 8082   | Gestión de propietarios      |
| `/pets/**`   | Pet Service      | 8083   | Gestión de mascotas          |
| `/alerts/**` | Alert Service    | 8084   | Sistema de alertas           |
| `/ai/**`     | AI Service       | 8000   | Reconocimiento biométrico    |

### Configuración CORS

```yaml
globalcors:
  corsConfigurations:
    "[/**]":
      allowedOriginPatterns: "*"
      allowedMethods: "*"
      allowedHeaders: "*"
      allowCredentials: true
```

## 📁 Archivos de Configuración

### 1. `gateway-service/src/main/resources/application.yml`

- **Configuración principal** del gateway
- **Rutas de enrutamiento** para todos los servicios
- **Configuración CORS** para el frontend
- **Timeouts** y configuraciones de cliente HTTP

### 2. `gateway-service/src/main/kotlin/com/petnow/gateway/config/GatewayConfig.kt`

- **Configuración comentada** para evitar conflictos
- **Reservado para configuraciones futuras** (producción, Docker, etc.)

### 3. `frontend/config/api.ts`

- **Configuración del cliente** para comunicación con el gateway
- **Detección automática** de IP para desarrollo/producción
- **Endpoints centralizados** para todas las APIs

## 🔄 Flujo de Peticiones

### 1. Frontend → Gateway

```
Frontend (localhost:19000)
    ↓ HTTP Request
Gateway (localhost:8080)
```

### 2. Gateway → Microservicios

```
Gateway (localhost:8080)
    ↓ Enrutamiento basado en Path
Microservicios (localhost:8081-8084, 8000)
```

### 3. Ejemplo de Flujo Completo

```
1. Frontend envía: POST http://localhost:8080/auth/login
2. Gateway recibe en: /auth/login
3. Gateway enruta a: http://localhost:8081/login
4. Auth Service procesa y responde
5. Gateway devuelve respuesta al Frontend
```

## 🛠️ Configuración para Desarrollo Local

### Variables de Entorno

```bash
# Gateway Service
GATEWAY_PORT=8080
GATEWAY_HOST=0.0.0.0

# Microservicios
AUTH_SERVICE_URL=http://localhost:8081
OWNER_SERVICE_URL=http://localhost:8082
PET_SERVICE_URL=http://localhost:8083
ALERT_SERVICE_URL=http://localhost:8084
AI_SERVICE_URL=http://localhost:8000
```

### Frontend Configuration

```typescript
const getLocalIP = (): string => {
  if (__DEV__) {
    return "localhost"; // Para desarrollo local
  }
  return "tu-ip-publica-o-dominio.com"; // Para producción
};
```

## 🔍 Verificación y Testing

### Script de Verificación

```bash
# Ejecutar verificación completa
./scripts/verify-gateway.sh
```

### Health Checks

```bash
# Gateway Health
curl http://localhost:8080/actuator/health

# Servicios individuales
curl http://localhost:8080/auth/health
curl http://localhost:8080/owners
curl http://localhost:8080/pets
curl http://localhost:8080/alerts
curl http://localhost:8080/ai/health
```

### Logs del Gateway

```bash
# Ver logs en tiempo real
tail -f gateway-service/logs/app.log

# Ver logs con filtros
grep "ERROR" gateway-service/logs/app.log
grep "DEBUG" gateway-service/logs/app.log
```

## 🚨 Solución de Problemas

### Problemas Comunes

#### 1. Gateway no responde

```bash
# Verificar si está ejecutándose
lsof -i :8080

# Reiniciar gateway
cd gateway-service
mvn spring-boot:run
```

#### 2. Rutas no funcionan

```bash
# Verificar configuración
cat gateway-service/src/main/resources/application.yml

# Verificar logs
tail -f gateway-service/logs/app.log
```

#### 3. CORS Errors

```bash
# Verificar configuración CORS en application.yml
# Asegurar que allowedOriginPatterns: "*" esté configurado
```

#### 4. Timeouts

```bash
# Aumentar timeouts en application.yml
httpclient:
  connect-timeout: 10000  # 10 segundos
  response-timeout: 60s   # 60 segundos
```

## 📊 Monitoreo

### Métricas Disponibles

- **Health Check**: `/actuator/health`
- **Info**: `/actuator/info`
- **Metrics**: `/actuator/metrics`
- **Gateway Routes**: `/actuator/gateway`

### Logs de Debug

```yaml
logging:
  level:
    com.petnow.gateway: DEBUG
    org.springframework.cloud.gateway: DEBUG
```

## 🔮 Configuración para Producción

### Cambios Necesarios

1. **IPs de servicios**: Cambiar `localhost` por IPs reales
2. **CORS**: Configurar orígenes específicos
3. **SSL/TLS**: Configurar certificados
4. **Load Balancing**: Configurar múltiples instancias
5. **Circuit Breakers**: Implementar resiliencia

### Ejemplo de Configuración de Producción

```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: auth-service
          uri: http://auth-service:8081 # Docker service name
        - id: owner-service
          uri: http://owner-service:8082
        # ... más rutas
```

## 📝 Notas Importantes

1. **Configuración Unificada**: Solo se usa `application.yml` para evitar conflictos
2. **Desarrollo Local**: Todos los servicios usan `localhost`
3. **CORS Configurado**: Permite acceso desde cualquier origen en desarrollo
4. **Logs Detallados**: Habilitados para debugging
5. **Health Checks**: Disponibles para monitoreo

## 🎯 Próximos Pasos

1. **Implementar autenticación** en el gateway
2. **Configurar rate limiting**
3. **Implementar circuit breakers**
4. **Agregar métricas personalizadas**
5. **Configurar para Docker/Producción**
