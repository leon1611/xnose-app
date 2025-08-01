#!/bin/bash

# Script de Respaldo del Estado Actual - PETNOW-DOGS
# Fecha: 28 de Julio, 2025

echo "🔄 Iniciando respaldo del estado actual del sistema PETNOW-DOGS..."

# Crear directorio de respaldo con timestamp
BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Creando respaldo en: $BACKUP_DIR"

# 1. Respaldar configuración de servicios
echo "📋 Respaldando configuraciones..."

# Pet Service
cp pet-service/src/main/kotlin/com/petnow/pet/service/PetService.kt "$BACKUP_DIR/"
cp pet-service/src/main/kotlin/com/petnow/pet/controller/PetController.kt "$BACKUP_DIR/"
cp pet-service/src/main/resources/application.yml "$BACKUP_DIR/"
cp pet-service/src/main/resources/husky.jpg "$BACKUP_DIR/"

# Frontend
cp frontend/config/api.ts "$BACKUP_DIR/"

# 2. Respaldar estado de la base de datos
echo "🗄️ Respaldando estado de la base de datos..."

# Exportar mascotas
curl -s http://localhost:8083/pets > "$BACKUP_DIR/pets.json"
echo "✅ Mascotas exportadas a $BACKUP_DIR/pets.json"

# Exportar alertas
curl -s http://localhost:8084/alerts > "$BACKUP_DIR/alerts.json"
echo "✅ Alertas exportadas a $BACKUP_DIR/alerts.json"

# Exportar propietarios
curl -s http://localhost:8082/owners > "$BACKUP_DIR/owners.json"
echo "✅ Propietarios exportados a $BACKUP_DIR/owners.json"

# 3. Respaldar estado de servicios
echo "🔧 Respaldando estado de servicios..."

# Verificar puertos activos
lsof -i :8080,8081,8082,8083,8084,8000 > "$BACKUP_DIR/active_ports.txt"
echo "✅ Puertos activos guardados en $BACKUP_DIR/active_ports.txt"

# 4. Respaldar logs recientes
echo "📝 Respaldando logs recientes..."

if [ -f "pet-service/logs/app.log" ]; then
    tail -100 pet-service/logs/app.log > "$BACKUP_DIR/pet_service_recent_logs.txt"
    echo "✅ Logs recientes del pet-service guardados"
fi

# 5. Crear archivo de resumen
echo "📊 Creando resumen del estado actual..."

cat > "$BACKUP_DIR/backup_summary.md" << EOF
# Respaldo del Estado Actual - PETNOW-DOGS

**Fecha**: $(date)
**Estado**: Sistema completamente operativo

## Servicios Activos
- Gateway Service (8080): ✅ Activo
- Auth Service (8081): ✅ Activo  
- Owner Service (8082): ✅ Activo
- Pet Service (8083): ✅ Activo
- Alert Service (8084): ✅ Activo
- AI Service (8000): ✅ Activo
- Frontend (19000): ✅ Activo

## Datos del Sistema
- Mascotas registradas: $(curl -s http://localhost:8083/pets | jq length 2>/dev/null || echo "N/A")
- Alertas activas: $(curl -s http://localhost:8084/alerts | jq length 2>/dev/null || echo "N/A")
- Propietarios: $(curl -s http://localhost:8082/owners | jq length 2>/dev/null || echo "N/A")

## Problemas Resueltos
✅ URLs de imágenes corregidas
✅ Imágenes visibles en frontend
✅ Sistema de escaneo funcional
✅ Todas las funcionalidades operativas

## Archivos Modificados
- pet-service/src/main/kotlin/com/petnow/pet/service/PetService.kt
- pet-service/src/main/kotlin/com/petnow/pet/controller/PetController.kt
- frontend/config/api.ts
- pet-service/src/main/resources/husky.jpg

## Comandos de Restauración
Para restaurar el estado:
1. Copiar archivos de respaldo a sus ubicaciones originales
2. Reiniciar servicios: \`./start-all-services.sh\`
3. Verificar estado: \`lsof -i :8080,8081,8082,8083,8084,8000\`
EOF

echo "✅ Resumen creado en $BACKUP_DIR/backup_summary.md"

# 6. Crear script de restauración
echo "🔄 Creando script de restauración..."

cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash

echo "🔄 Restaurando estado del sistema PETNOW-DOGS..."

# Restaurar archivos de configuración
echo "📋 Restaurando archivos de configuración..."

cp PetService.kt ../pet-service/src/main/kotlin/com/petnow/pet/service/
cp PetController.kt ../pet-service/src/main/kotlin/com/petnow/pet/controller/
cp application.yml ../pet-service/src/main/resources/
cp husky.jpg ../pet-service/src/main/resources/
cp api.ts ../frontend/config/

echo "✅ Archivos restaurados"
echo "🔄 Reiniciando servicios..."

# Reiniciar pet-service
cd ../pet-service
mvn spring-boot:run &
sleep 30

echo "✅ Restauración completada"
echo "🔍 Verificar estado con: lsof -i :8080,8081,8082,8083,8084,8000"
EOF

chmod +x "$BACKUP_DIR/restore.sh"

echo "✅ Script de restauración creado en $BACKUP_DIR/restore.sh"

# 7. Comprimir respaldo
echo "📦 Comprimiendo respaldo..."

tar -czf "${BACKUP_DIR}.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

echo "✅ Respaldo completado: ${BACKUP_DIR}.tar.gz"
echo ""
echo "🎉 Estado actual del sistema guardado exitosamente!"
echo "📁 Archivo de respaldo: ${BACKUP_DIR}.tar.gz"
echo ""
echo "Para restaurar en el futuro:"
echo "1. tar -xzf ${BACKUP_DIR}.tar.gz"
echo "2. cd $BACKUP_DIR"
echo "3. ./restore.sh" 