# PETNOW-DOGS 🐕

Sistema de identificación biométrica de mascotas mediante reconocimiento de huella nasal usando inteligencia artificial.

## 🚀 Características Principales

- **Identificación Biométrica**: Reconocimiento único de mascotas por huella nasal
- **Aplicación Móvil**: Frontend React Native con Expo para iOS y Android
- **Arquitectura de Microservicios**: Backend distribuido con Spring Boot y Python
- **Inteligencia Artificial**: Modelo de embeddings para comparación de imágenes
- **Gestión Completa**: Registro de mascotas, propietarios y alertas
- **API Gateway**: Punto de entrada unificado para todos los servicios

## 🏗️ Arquitectura del Sistema

### Microservicios

| Servicio            | Puerto | Tecnología   | Descripción                  |
| ------------------- | ------ | ------------ | ---------------------------- |
| **Gateway Service** | 8080   | Spring Boot  | API Gateway y enrutamiento   |
| **Auth Service**    | 8081   | Spring Boot  | Autenticación y autorización |
| **Owner Service**   | 8082   | Spring Boot  | Gestión de propietarios      |
| **Pet Service**     | 8083   | Spring Boot  | Gestión de mascotas          |
| **Alert Service**   | 8084   | Spring Boot  | Sistema de alertas           |
| **AI Service**      | 8000   | Python/Flask | Reconocimiento biométrico    |

### Frontend

- **React Native** con Expo
- **TypeScript** para type safety
- **Context API** para gestión de estado
- **Axios** para comunicación con APIs
- **Expo Image Picker** para captura de imágenes

## 🛠️ Instalación y Configuración

### Prerequisitos

- **Java 17+** y **Maven 3.6+**
- **Python 3.8+** y **pip**
- **Node.js 18+** y **npm**
- **Git**

### Configuración Rápida

1. **Clonar el repositorio**

   ```bash
   git clone <repository-url>
   cd PETNOW-DOGS
   ```

2. **Configurar entorno**

   ```bash
   ./dev-setup.sh
   ```

3. **Iniciar todos los servicios**

   ```bash
   ./start-all-services.sh
   ```

4. **Iniciar frontend**
   ```bash
   cd frontend
   npm start
   ```

## 📱 Uso del Frontend

### Pantalla de Escaneo Mejorada

La pantalla de escaneo incluye las siguientes mejoras:

- **Captura de Imágenes**: Opción para tomar foto o seleccionar de galería
- **Validación de Permisos**: Solicitud automática de permisos de cámara y galería
- **Procesamiento Optimizado**: Imágenes cuadradas para mejor reconocimiento
- **Feedback Visual**: Indicadores de carga y barras de progreso
- **Manejo de Errores**: Mensajes específicos para diferentes tipos de errores
- **UI/UX Moderna**: Diseño intuitivo con temas claro/oscuro

### Flujo de Escaneo

1. **Selección de Imagen**: Tomar foto o seleccionar de galería
2. **Validación**: Verificar que la imagen sea clara y enfocada
3. **Procesamiento**: Envío al AI Service para análisis
4. **Resultado**: Visualización de coincidencias con nivel de confianza
5. **Acciones**: Opciones para escanear otra mascota o ver detalles

## 🔧 Scripts de Administración

### Scripts Principales

| Script                  | Descripción                                  |
| ----------------------- | -------------------------------------------- |
| `start-all-services.sh` | Inicia todos los microservicios en orden     |
| `cleanup-ports.sh`      | Detiene todos los servicios y limpia puertos |
| `monitor-services.sh`   | Monitorea el estado de todos los servicios   |
| `dev-setup.sh`          | Configura el entorno de desarrollo           |

### Scripts de Base de Datos

| Script          | Ubicación  | Descripción             |
| --------------- | ---------- | ----------------------- |
| `backup-db.sh`  | `scripts/` | Respaldar base de datos |
| `restore-db.sh` | `scripts/` | Restaurar base de datos |

### Uso de Scripts

```bash
# Iniciar sistema completo
./start-all-services.sh

# Monitorear servicios
./monitor-services.sh

# Detener todos los servicios
./cleanup-ports.sh

# Ver logs en tiempo real
tail -f logs/*.log
```

## 🔍 API Endpoints

### Gateway Service (Puerto 8080)

| Método | Endpoint         | Descripción         |
| ------ | ---------------- | ------------------- |
| POST   | `/auth/login`    | Iniciar sesión      |
| POST   | `/auth/register` | Registrar usuario   |
| GET    | `/owners`        | Listar propietarios |
| POST   | `/owners`        | Crear propietario   |
| GET    | `/pets`          | Listar mascotas     |
| POST   | `/pets`          | Crear mascota       |
| POST   | `/scan`          | Escanear mascota    |
| GET    | `/alerts`        | Listar alertas      |
| POST   | `/alerts`        | Crear alerta        |

### AI Service (Puerto 8000)

| Método | Endpoint    | Descripción                    |
| ------ | ----------- | ------------------------------ |
| POST   | `/register` | Registrar embedding de mascota |
| POST   | `/scan`     | Comparar imagen con embeddings |
| GET    | `/health`   | Estado del servicio            |

## 🧪 Pruebas del Sistema

### Prueba de Escaneo

1. **Registrar una mascota** con foto de la nariz
2. **Escanear la misma imagen** para verificar reconocimiento
3. **Probar con imágenes diferentes** para validar precisión

### Prueba de Flujo Completo

1. Crear propietario
2. Registrar mascota con foto de nariz
3. Crear alerta de mascota perdida
4. Escanear imagen para identificar mascota
5. Verificar coincidencias y nivel de confianza

## 📊 Monitoreo y Logs

### Logs de Servicios

Los logs se almacenan en el directorio `logs/`:

- `Gateway Service.log`
- `Auth Service.log`
- `Owner Service.log`
- `Pet Service.log`
- `Alert Service.log`
- `AI Service.log`

### Monitoreo en Tiempo Real

```bash
# Ver logs de todos los servicios
tail -f logs/*.log

# Ver logs de un servicio específico
tail -f logs/AI\ Service.log

# Monitorear recursos del sistema
./monitor-services.sh
```

## 🚨 Solución de Problemas

### Problemas Comunes

1. **Puertos ocupados**

   ```bash
   ./cleanup-ports.sh
   ```

2. **Servicios no inician**

   ```bash
   ./monitor-services.sh
   tail -f logs/*.log
   ```

3. **Errores de conexión**

   - Verificar que todos los servicios estén activos
   - Comprobar configuración de IP en `frontend/config/api.ts`

4. **Problemas de frontend**
   ```bash
   cd frontend
   npm install
   npm start --clear
   ```

### Verificación de Estado

```bash
# Verificar puertos activos
lsof -i :8080,8081,8082,8083,8084,8000

# Verificar procesos
ps aux | grep -E "(java|python3)" | grep petnow

# Verificar logs de errores
grep -i "error\|exception" logs/*.log
```

## 🔒 Seguridad

- **Autenticación JWT** para todas las operaciones
- **Validación de entrada** en todos los endpoints
- **Manejo seguro de archivos** para imágenes
- **Logs de auditoría** para operaciones críticas

## 📈 Rendimiento

### Optimizaciones Implementadas

- **Timeouts extendidos** para operaciones de IA (45s)
- **Compresión de imágenes** antes del envío
- **Caché de embeddings** para comparaciones rápidas
- **Logging optimizado** con niveles apropiados

### Métricas de Rendimiento

- **Tiempo de escaneo**: < 30 segundos
- **Precisión de reconocimiento**: > 80%
- **Umbral de similitud**: 0.80 configurable

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Soporte

Para soporte técnico o preguntas:

- Revisar la documentación en `docs/`
- Verificar logs en `logs/`
- Ejecutar `./monitor-services.sh` para diagnóstico
- Crear issue en el repositorio

---

**PETNOW-DOGS** - Identificación biométrica de mascotas con IA 🐕✨
