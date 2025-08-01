# 🚀 Guía de Inicio Rápido - PETNOW-DOGS

## 📋 Prerequisitos

Antes de comenzar, asegúrate de tener instalado:

- **Docker** y **Docker Compose**
- **Node.js 18+** (para el frontend)
- **Java 17+** (para desarrollo local de microservicios)
- **Maven** (para desarrollo local)

## 🎯 Inicio Rápido (5 minutos)

### 1. Configuración Inicial

```bash
# Clonar el repositorio (si no lo has hecho)
git clone <repository-url>
cd PETNOW-DOGS

# Ejecutar configuración automática
./dev-setup.sh
```

### 2. Iniciar el Proyecto

```bash
# Iniciar todos los servicios
./start-project.sh
```

### 3. Verificar que Todo Funciona

```bash
# Verificar estado de servicios
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f
```

### 4. Acceder a las Aplicaciones

- **API Gateway**: http://localhost:8080
- **Documentación Swagger**: http://localhost:8080/swagger-ui.html
- **Frontend**: Ejecutar `cd frontend && npm start`

## 📱 Frontend Móvil

### Instalación

```bash
cd frontend
npm install --legacy-peer-deps
npm start
```

### Uso

1. Instala **Expo Go** en tu dispositivo móvil
2. Escanea el código QR que aparece en la terminal
3. La app se abrirá automáticamente

## 🔧 Desarrollo Local

### Backend (Microservicios)

```bash
# Ejecutar solo la base de datos
docker-compose up postgres -d

# Ejecutar un microservicio específico
cd auth-service
./mvnw spring-boot:run
```

### Frontend

```bash
cd frontend
npm start
```

## 🧪 Testing

### Backend

```bash
# Ejecutar tests de todos los servicios
docker-compose exec auth-service ./mvnw test
docker-compose exec owner-service ./mvnw test
docker-compose exec pet-service ./mvnw test
docker-compose exec alert-service ./mvnw test
docker-compose exec scan-service ./mvnw test
```

### Frontend

```bash
cd frontend
npm test
```

## 📊 Monitoreo

### Health Checks

```bash
# Verificar estado de todos los servicios
curl http://localhost:8080/actuator/health  # Gateway
curl http://localhost:8081/actuator/health  # Auth
curl http://localhost:8082/actuator/health  # Owner
curl http://localhost:8083/actuator/health  # Pet
curl http://localhost:8084/actuator/health  # Alert
curl http://localhost:8085/health           # AI
curl http://localhost:8086/actuator/health  # Scan
```

### Logs

```bash
# Ver logs de todos los servicios
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f auth-service
```

## 🛠️ Comandos Útiles

```bash
# Detener todos los servicios
docker-compose down

# Reiniciar servicios
docker-compose restart

# Reconstruir servicios
docker-compose up -d --build

# Ver uso de recursos
docker stats

# Limpiar recursos no utilizados
docker system prune
```

## 🔒 Configuración de Seguridad

### Variables de Entorno

Edita el archivo `.env` para configurar:

- Claves JWT
- Credenciales de base de datos
- Configuración de Google Cloud Storage
- URLs de servicios

### Google Cloud Storage

Para usar el almacenamiento de imágenes:

1. Crea un proyecto en Google Cloud
2. Habilita Cloud Storage
3. Crea un bucket
4. Genera una clave de servicio
5. Configura las variables en `.env`

## 🐛 Solución de Problemas

### Error de Puerto en Uso

```bash
# Ver qué está usando el puerto
lsof -i :8080

# Detener el proceso
kill -9 <PID>
```

### Error de Base de Datos

```bash
# Reiniciar solo la base de datos
docker-compose restart postgres

# Ver logs de la base de datos
docker-compose logs postgres
```

### Error de Dependencias Frontend

```bash
cd frontend
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
```

### Error de Permisos Docker

```bash
# En macOS/Linux
sudo chown -R $USER:$USER ~/.docker
```

## 📞 Soporte

Si encuentras problemas:

1. Revisa los logs: `docker-compose logs -f`
2. Verifica la configuración en `.env`
3. Asegúrate de que todos los prerequisitos estén instalados
4. Consulta la documentación completa en `README.md`

## 🎉 ¡Listo!

¡Tu proyecto PETNOW-DOGS está funcionando! Ahora puedes:

- Registrar usuarios y mascotas
- Escanear huellas nasales
- Crear alertas de mascotas perdidas
- Usar la app móvil para interactuar con el sistema

¡Disfruta desarrollando con PETNOW-DOGS! 🐕 