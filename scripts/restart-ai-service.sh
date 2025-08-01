#!/bin/bash

echo "🤖 REINICIANDO AI SERVICE CON MODELO AVANZADO"
echo "=============================================="

# Función para verificar si un puerto está en uso
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        return 0
    else
        return 1
    fi
}

# Función para detener el AI Service
stop_ai_service() {
    echo "🛑 Deteniendo AI Service..."
    
    # Buscar procesos de Python en el puerto 8000
    AI_PIDS=$(lsof -ti:8000 2>/dev/null)
    
    if [ ! -z "$AI_PIDS" ]; then
        echo "   Encontrados procesos en puerto 8000: $AI_PIDS"
        for pid in $AI_PIDS; do
            echo "   Deteniendo proceso $pid..."
            kill -TERM $pid 2>/dev/null
            sleep 2
            if kill -0 $pid 2>/dev/null; then
                echo "   Forzando terminación del proceso $pid..."
                kill -KILL $pid 2>/dev/null
            fi
        done
        echo "✅ AI Service detenido"
    else
        echo "ℹ️  No se encontraron procesos en puerto 8000"
    fi
}

# Función para verificar dependencias
check_dependencies() {
    echo "🔍 Verificando dependencias..."
    
    # Verificar si existe el directorio del AI Service
    if [ ! -d "ai-service" ]; then
        echo "❌ Directorio ai-service no encontrado"
        exit 1
    fi
    
    # Verificar si existe el entorno virtual
    if [ ! -d "ai-service/venv" ]; then
        echo "❌ Entorno virtual no encontrado en ai-service/venv"
        echo "   Ejecuta: cd ai-service && python3 -m venv venv"
        exit 1
    fi
    
    # Verificar archivos del modelo
    if [ ! -f "ai-service/advanced_nose_model.py" ]; then
        echo "❌ Modelo avanzado no encontrado: advanced_nose_model.py"
        exit 1
    fi
    
    if [ ! -f "ai-service/main.py" ]; then
        echo "❌ Archivo principal no encontrado: main.py"
        exit 1
    fi
    
    echo "✅ Dependencias verificadas"
}

# Función para instalar dependencias adicionales
install_dependencies() {
    echo "📦 Instalando dependencias adicionales..."
    
    cd ai-service
    
    # Activar entorno virtual
    source venv/bin/activate
    
    # Instalar scikit-learn si no está instalado
    if ! python -c "import sklearn" 2>/dev/null; then
        echo "   Instalando scikit-learn..."
        pip install scikit-learn
    fi
    
    # Verificar otras dependencias
    echo "   Verificando dependencias..."
    python -c "
import tensorflow as tf
import cv2
import numpy as np
import sklearn
print('✅ Todas las dependencias están instaladas')
"
    
    cd ..
}

# Función para iniciar el AI Service
start_ai_service() {
    echo "🚀 Iniciando AI Service con modelo avanzado..."
    
    cd ai-service
    
    # Activar entorno virtual
    source venv/bin/activate
    
    # Iniciar el servicio en segundo plano
    echo "   Ejecutando: python main.py"
    nohup python main.py > ai_service.log 2>&1 &
    AI_PID=$!
    
    cd ..
    
    echo "   PID del AI Service: $AI_PID"
    
    # Esperar a que el servicio esté listo
    echo "⏳ Esperando a que el servicio esté listo..."
    for i in {1..30}; do
        if check_port 8000; then
            echo "✅ AI Service iniciado correctamente en puerto 8000"
            return 0
        fi
        echo "   Intentando conexión... ($i/30)"
        sleep 2
    done
    
    echo "❌ AI Service no se inició correctamente"
    return 1
}

# Función para verificar el estado del servicio
verify_service() {
    echo "🔍 Verificando estado del servicio..."
    
    # Esperar un momento adicional
    sleep 3
    
    # Probar health check
    if curl -s http://localhost:8000/health > /dev/null; then
        echo "✅ Health check exitoso"
        
        # Obtener detalles del health check
        HEALTH_RESPONSE=$(curl -s http://localhost:8000/health)
        echo "📊 Estado del servicio:"
        echo "$HEALTH_RESPONSE" | python3 -m json.tool
        
        return 0
    else
        echo "❌ Health check falló"
        return 1
    fi
}

# Función para mostrar logs
show_logs() {
    echo "📋 Últimas líneas del log del AI Service:"
    if [ -f "ai-service/ai_service.log" ]; then
        tail -20 ai-service/ai_service.log
    else
        echo "   No se encontró archivo de log"
    fi
}

# Función para probar el modelo
test_model() {
    echo "🧪 Probando modelo avanzado..."
    
    cd ai-service
    
    # Activar entorno virtual
    source venv/bin/activate
    
    # Ejecutar script de prueba
    if [ -f "test_advanced_model.py" ]; then
        echo "   Ejecutando pruebas..."
        python test_advanced_model.py
    else
        echo "   Script de prueba no encontrado"
    fi
    
    cd ..
}

# Función principal
main() {
    echo "🕐 $(date)"
    echo ""
    
    # Verificar dependencias
    check_dependencies
    
    # Detener servicio existente
    stop_ai_service
    
    # Esperar un momento
    sleep 3
    
    # Verificar que el puerto esté libre
    if check_port 8000; then
        echo "❌ Puerto 8000 aún está en uso"
        exit 1
    fi
    
    # Instalar dependencias
    install_dependencies
    
    # Iniciar servicio
    if start_ai_service; then
        # Verificar estado
        if verify_service; then
            echo ""
            echo "🎉 AI SERVICE REINICIADO EXITOSAMENTE"
            echo "====================================="
            echo "✅ Modelo avanzado cargado"
            echo "✅ Servicio corriendo en puerto 8000"
            echo "✅ Endpoints disponibles:"
            echo "   - Health: http://localhost:8000/health"
            echo "   - Register: http://localhost:8000/register-embedding"
            echo "   - Compare: http://localhost:8000/compare"
            echo "   - Scan: http://localhost:8000/scan"
            echo "   - Stats: http://localhost:8000/model-stats"
            echo ""
            echo "🧪 Para probar el modelo:"
            echo "   cd ai-service && source venv/bin/activate && python test_advanced_model.py"
            echo ""
            
            # Mostrar logs
            show_logs
            
            # Preguntar si quiere probar el modelo
            echo ""
            read -p "¿Quieres probar el modelo ahora? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                test_model
            fi
        else
            echo "❌ Verificación del servicio falló"
            show_logs
            exit 1
        fi
    else
        echo "❌ No se pudo iniciar el AI Service"
        show_logs
        exit 1
    fi
}

# Ejecutar función principal
main 