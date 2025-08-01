#!/bin/bash

echo "💾 RESPALDO DE CONFIGURACIÓN FUNCIONAL"
echo "======================================"
echo ""

# Crear directorio de respaldo
BACKUP_DIR="backup-working-config-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Creando respaldo en: $BACKUP_DIR"
echo ""

# Función para respaldar archivos de configuración
backup_config_files() {
    echo "📋 Respaldando archivos de configuración..."
    
    # Frontend
    cp frontend/config/api.ts "$BACKUP_DIR/frontend-api-config.ts"
    cp frontend/services/api.ts "$BACKUP_DIR/frontend-api-service.ts"
    cp frontend/contexts/AuthContext.tsx "$BACKUP_DIR/frontend-auth-context.tsx"
    
    # Gateway
    cp gateway-service/src/main/resources/application.yml "$BACKUP_DIR/gateway-config.yml"
    cp gateway-service/src/main/kotlin/com/petnow/gateway/config/GatewayConfig.kt "$BACKUP_DIR/gateway-config.kt"
    
    # Owner Service
    cp owner-service/src/main/kotlin/com/petnow/owner/service/OwnerService.kt "$BACKUP_DIR/owner-service.kt"
    cp owner-service/src/main/kotlin/com/petnow/owner/controller/OwnerController.kt "$BACKUP_DIR/owner-controller.kt"
    cp owner-service/src/main/kotlin/com/petnow/owner/dto/OwnerDto.kt "$BACKUP_DIR/owner-dto.kt"
    
    # Pet Service
    cp pet-service/src/main/kotlin/com/petnow/pet/controller/PetController.kt "$BACKUP_DIR/pet-controller.kt"
    
    # Alert Service
    cp alert-service/src/main/kotlin/com/petnow/alert/service/AlertService.kt "$BACKUP_DIR/alert-service.kt"
    cp alert-service/src/main/kotlin/com/petnow/alert/controller/AlertController.kt "$BACKUP_DIR/alert-controller.kt"
    cp alert-service/src/main/kotlin/com/petnow/alert/dto/AlertDto.kt "$BACKUP_DIR/alert-dto.kt"
    
    echo "✅ Archivos de configuración respaldados"
    echo ""
}

# Función para crear documentación del estado actual
create_documentation() {
    echo "📝 Creando documentación del estado actual..."
    
    cat > "$BACKUP_DIR/ESTADO_ACTUAL.md" << 'EOF'
# 🎯 ESTADO ACTUAL DEL SISTEMA - CONFIGURACIÓN FUNCIONAL

## 📅 Fecha de Respaldo
$(date)

## ✅ CONFIGURACIÓN IMPLEMENTADA Y FUNCIONANDO

### 🔧 Aislamiento de Datos por Usuario
- **👥 Propietarios**: Privados por usuario (filtrados por `userId`)
- **🐕 Mascotas**: Privadas por usuario (filtradas por `userId`)
- **🚨 Alertas**: Compartidas globalmente (sin filtro de usuario)
- **🔍 Escáner**: Accede a todas las mascotas (necesario para IA)

### 🌐 Configuración de Red
- **Frontend**: `192.168.0.104:19000` (IP local para acceso móvil)
- **Gateway**: `192.168.0.104:8080` (punto de entrada único)
- **Servicios**: `localhost:8081-8084` (microservicios)

### 📱 Funcionalidades Implementadas
- ✅ Autenticación de usuarios
- ✅ Registro de propietarios (privado por usuario)
- ✅ Registro de mascotas (privado por usuario)
- ✅ Sistema de alertas (compartido globalmente)
- ✅ Limpieza automática de formularios
- ✅ Escáner biométrico (acceso global a mascotas)

## 🔍 Endpoints Disponibles

### Gateway (Puerto 8080)
- `GET /actuator/health` - Health check
- `POST /auth/register` - Registro de usuarios
- `POST /auth/login` - Login de usuarios
- `GET /owners/user/{userId}` - Propietarios por usuario
- `GET /pets/user/{userId}` - Mascotas por usuario
- `GET /alerts` - Alertas globales

### Servicios Directos
- **Auth Service**: `http://localhost:8081`
- **Owner Service**: `http://localhost:8082`
- **Pet Service**: `http://localhost:8083`
- **Alert Service**: `http://localhost:8084`

## 🚨 PROBLEMAS CONOCIDOS

### ⚠️ AI Service - No Funcionando Correctamente
- **Problema**: El servicio de IA no está reconociendo mascotas correctamente
- **Estado**: Pendiente de revisión y corrección
- **Impacto**: El escáner biométrico no funciona al 100%
- **Solución**: Requiere revisión del modelo de IA y configuración

## 📋 Archivos Modificados

### Frontend
- `frontend/config/api.ts` - Configuración de IP y endpoints
- `frontend/services/api.ts` - Filtrado por usuario
- `frontend/contexts/AuthContext.tsx` - Limpieza de formularios

### Backend
- `gateway-service/src/main/resources/application.yml` - Configuración del gateway
- `owner-service/` - Filtrado por usuario
- `pet-service/` - Filtrado por usuario
- `alert-service/` - Configuración global

## 🧪 Pruebas Realizadas

### ✅ Funcionando Correctamente
- [x] Registro de usuarios
- [x] Login de usuarios
- [x] Creación de propietarios (aislado por usuario)
- [x] Creación de mascotas (aislado por usuario)
- [x] Creación de alertas (compartidas)
- [x] Limpieza de formularios
- [x] Conexión frontend-backend
- [x] Gateway routing

### ❌ No Funcionando
- [ ] Escáner biométrico (problema con AI Service)
- [ ] Reconocimiento de mascotas por IA

## 🚀 Instrucciones de Uso

### Para Desarrolladores
1. Ejecutar `./scripts/restart-services.sh` para iniciar todos los servicios
2. Ejecutar `cd frontend && npm start` para iniciar el frontend
3. Conectar desde móvil: `exp://192.168.0.104:19000`

### Para Usuarios
1. Abrir Expo Go en el móvil
2. Escanear: `exp://192.168.0.104:19000`
3. Registrarse como nuevo usuario
4. Usar todas las funcionalidades excepto el escáner

## 📊 Estado de Servicios

- ✅ Gateway Service: Puerto 8080
- ✅ Auth Service: Puerto 8081
- ✅ Owner Service: Puerto 8082
- ✅ Pet Service: Puerto 8083
- ✅ Alert Service: Puerto 8084
- ✅ Frontend: Puerto 19000
- ❌ AI Service: Puerto 8000 (problemas)

## 💡 Notas Importantes

1. **Aislamiento de Datos**: Cada usuario ve solo sus propietarios y mascotas
2. **Alertas Compartidas**: Todos los usuarios ven todas las alertas
3. **Escáner**: Requiere revisión del AI Service
4. **Formularios**: Se limpian automáticamente al registrar
5. **IP Configuración**: Usar `192.168.0.104` para acceso móvil

## 🔄 Restauración

Para restaurar esta configuración:
1. Copiar archivos del respaldo a sus ubicaciones originales
2. Ejecutar `./scripts/restart-services.sh`
3. Verificar con `./scripts/verify-final-setup.sh`
EOF

    echo "✅ Documentación creada: $BACKUP_DIR/ESTADO_ACTUAL.md"
    echo ""
}

# Función para crear script de restauración
create_restore_script() {
    echo "🔄 Creando script de restauración..."
    
    cat > "$BACKUP_DIR/restore-config.sh" << 'EOF'
#!/bin/bash

echo "🔄 RESTAURANDO CONFIGURACIÓN FUNCIONAL"
echo "======================================"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "frontend/config/api.ts" ]; then
    echo "❌ Error: Debes ejecutar este script desde el directorio raíz del proyecto"
    exit 1
fi

echo "📋 Restaurando archivos de configuración..."

# Frontend
cp frontend-api-config.ts frontend/config/api.ts
cp frontend-api-service.ts frontend/services/api.ts
cp frontend-auth-context.tsx frontend/contexts/AuthContext.tsx

# Gateway
cp gateway-config.yml gateway-service/src/main/resources/application.yml
cp gateway-config.kt gateway-service/src/main/kotlin/com/petnow/gateway/config/GatewayConfig.kt

# Owner Service
cp owner-service.kt owner-service/src/main/kotlin/com/petnow/owner/service/OwnerService.kt
cp owner-controller.kt owner-service/src/main/kotlin/com/petnow/owner/controller/OwnerController.kt
cp owner-dto.kt owner-service/src/main/kotlin/com/petnow/owner/dto/OwnerDto.kt

# Pet Service
cp pet-controller.kt pet-service/src/main/kotlin/com/petnow/pet/controller/PetController.kt

# Alert Service
cp alert-service.kt alert-service/src/main/kotlin/com/petnow/alert/service/AlertService.kt
cp alert-controller.kt alert-service/src/main/kotlin/com/petnow/alert/controller/AlertController.kt
cp alert-dto.kt alert-service/src/main/kotlin/com/petnow/alert/dto/AlertDto.kt

echo "✅ Archivos restaurados"
echo ""
echo "🔄 Reiniciando servicios..."
./scripts/restart-services.sh

echo ""
echo "🎉 ¡Configuración restaurada exitosamente!"
echo "💡 Verifica con: ./scripts/verify-final-setup.sh"
EOF

    chmod +x "$BACKUP_DIR/restore-config.sh"
    echo "✅ Script de restauración creado: $BACKUP_DIR/restore-config.sh"
    echo ""
}

# Función para crear resumen
create_summary() {
    echo "📊 Creando resumen del respaldo..."
    
    cat > "$BACKUP_DIR/RESUMEN.md" << EOF
# 📊 RESUMEN DEL RESPALDO

## 📅 Información del Respaldo
- **Fecha**: $(date)
- **Directorio**: $BACKUP_DIR
- **Estado**: Configuración funcional (excepto AI Service)

## ✅ Funcionalidades Respaldadas
- Aislamiento de datos por usuario
- Configuración de red correcta
- Limpieza automática de formularios
- Sistema de alertas compartidas
- Gateway y microservicios funcionando

## ❌ Problemas Conocidos
- AI Service no reconoce mascotas correctamente
- Escáner biométrico no funciona al 100%

## 📁 Archivos Incluidos
- Configuraciones de frontend y backend
- Servicios y controladores modificados
- DTOs actualizados
- Scripts de verificación y restauración

## 🚀 Próximos Pasos
1. Revisar y corregir AI Service
2. Probar escáner biométrico
3. Documentar solución del AI Service

## 💾 Para Restaurar
\`\`\`bash
cd $BACKUP_DIR
./restore-config.sh
\`\`\`
EOF

    echo "✅ Resumen creado: $BACKUP_DIR/RESUMEN.md"
    echo ""
}

# Ejecutar funciones
backup_config_files
create_documentation
create_restore_script
create_summary

# Mostrar resumen final
echo "🎉 ¡RESPALDO COMPLETADO EXITOSAMENTE!"
echo "====================================="
echo ""
echo "📁 Directorio de respaldo: $BACKUP_DIR"
echo ""
echo "📋 Archivos respaldados:"
ls -la "$BACKUP_DIR"
echo ""
echo "📝 Documentación creada:"
echo "   - ESTADO_ACTUAL.md (documentación completa)"
echo "   - RESUMEN.md (resumen ejecutivo)"
echo "   - restore-config.sh (script de restauración)"
echo ""
echo "💡 Para restaurar en el futuro:"
echo "   cd $BACKUP_DIR"
echo "   ./restore-config.sh"
echo ""
echo "🎯 Estado guardado:"
echo "   ✅ Configuración funcional respaldada"
echo "   ⚠️ AI Service pendiente de corrección"
echo "   📱 Frontend y backend funcionando"
echo "" 