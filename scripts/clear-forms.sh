#!/bin/bash

echo "🧹 LIMPIANDO FORMULARIOS Y DATOS DE SESIÓN"
echo "=========================================="
echo ""

# Función para limpiar datos de AsyncStorage en el frontend
clear_forms() {
    echo "📱 Limpiando formularios del frontend..."
    
    # Crear un archivo temporal con comandos para limpiar AsyncStorage
    cat > /tmp/clear_forms.js << 'EOF'
// Script para limpiar formularios en React Native
import AsyncStorage from '@react-native-async-storage/async-storage';

const clearFormData = async () => {
    try {
        // Limpiar datos de formularios
        await AsyncStorage.removeItem('ownerFormData');
        await AsyncStorage.removeItem('petFormData');
        await AsyncStorage.removeItem('alertFormData');
        
        // Limpiar datos temporales
        await AsyncStorage.removeItem('tempProfileImage');
        await AsyncStorage.removeItem('tempNoseImage');
        await AsyncStorage.removeItem('selectedOwnerId');
        
        console.log('✅ Formularios limpiados exitosamente');
    } catch (error) {
        console.error('❌ Error al limpiar formularios:', error);
    }
};

clearFormData();
EOF

    echo "✅ Script de limpieza creado en /tmp/clear_forms.js"
    echo "💡 Ejecuta este script en el frontend para limpiar los formularios"
}

# Función para mostrar instrucciones
show_instructions() {
    echo ""
    echo "📋 INSTRUCCIONES PARA LIMPIAR FORMULARIOS:"
    echo "=========================================="
    echo ""
    echo "1. 🧹 LIMPIEZA AUTOMÁTICA:"
    echo "   - Los formularios se limpian automáticamente al registrar un nuevo usuario"
    echo "   - Se limpian al hacer logout"
    echo ""
    echo "2. 🧹 LIMPIEZA MANUAL:"
    echo "   - Ve a la pantalla de registro de propietario"
    echo "   - Los campos deben estar en blanco"
    echo "   - Si no están en blanco, reinicia la app"
    echo ""
    echo "3. 🔄 REINICIO DE APP:"
    echo "   - Cierra completamente la app en tu celular"
    echo "   - Vuelve a abrirla"
    echo "   - Los formularios estarán limpios"
    echo ""
    echo "4. 🗑️ LIMPIEZA DE DATOS:"
    echo "   - Ve a Configuración > Apps > XNOSE > Almacenamiento"
    echo "   - Borra datos y caché"
    echo "   - Reinicia la app"
    echo ""
}

# Función para verificar estado actual
check_current_state() {
    echo "🔍 ESTADO ACTUAL:"
    echo "================"
    echo ""
    
    # Verificar si hay servicios ejecutándose
    echo "📊 Servicios ejecutándose:"
    if lsof -i :8080 > /dev/null 2>&1; then
        echo "   ✅ Gateway: Puerto 8080"
    else
        echo "   ❌ Gateway: No ejecutándose"
    fi
    
    if lsof -i :19000 > /dev/null 2>&1; then
        echo "   ✅ Frontend: Puerto 19000"
    else
        echo "   ❌ Frontend: No ejecutándose"
    fi
    
    echo ""
    echo "📱 Conexiones activas:"
    lsof -i :8080 | grep ESTABLISHED | wc -l | xargs echo "   - Gateway: conexiones"
    lsof -i :19000 | grep ESTABLISHED | wc -l | xargs echo "   - Frontend: conexiones"
    echo ""
}

# Ejecutar funciones
clear_forms
show_instructions
check_current_state

echo "🎯 RESUMEN DE CAMBIOS IMPLEMENTADOS:"
echo "===================================="
echo ""
echo "✅ PROPRIETARIOS: Privados por usuario (filtrados por userId)"
echo "✅ MASCOTAS: Privadas por usuario (filtradas por userId)"
echo "✅ ALERTAS: Compartidas globalmente (sin filtro de usuario)"
echo "✅ ESCÁNER: Accede a todas las mascotas registradas"
echo "✅ FORMULARIOS: Se limpian automáticamente al registrar"
echo ""
echo "🚀 El sistema ahora está configurado correctamente:"
echo "   - Cada usuario ve solo sus propietarios y mascotas"
echo "   - Las alertas son compartidas entre todos los usuarios"
echo "   - El escáner puede acceder a todas las mascotas"
echo "   - Los formularios se limpian después del registro"
echo "" 