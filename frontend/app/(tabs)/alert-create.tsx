import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  SafeAreaView,
} from 'react-native';
import { useRouter, useLocalSearchParams, useFocusEffect } from 'expo-router';
import { Picker } from '@react-native-picker/picker';
import { apiService } from '../../services/api';
import { useTheme } from '../../contexts/ThemeContext';
import Colors from '../../constants/Colors';
import CustomHeader from '../../components/CustomHeader';

export default function AlertCreateScreen() {
  const [type, setType] = useState<'LOST' | 'FOUND'>('LOST');
  const [petId, setPetId] = useState<string>('');
  const [location, setLocation] = useState('');
  const [description, setDescription] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isLoadingPets, setIsLoadingPets] = useState(true);
  const [pets, setPets] = useState<any[]>([]);

  
  const router = useRouter();
  const params = useLocalSearchParams();
  const { theme } = useTheme();
  const colors = Colors[theme];

  useEffect(() => {
    loadPets();
  }, []); // Solo se ejecuta una vez al montar el componente

  // Refrescar mascotas cuando se enfoque la pantalla
  useFocusEffect(
    React.useCallback(() => {
      console.log('🔄 Pantalla de creación de alertas enfocada, refrescando mascotas...');
      loadPets();
    }, [])
  );

  const loadPets = async () => {
    try {
      setIsLoadingPets(true);
      console.log('🔄 Cargando mascotas para alerta...');
      const petsList = await apiService.getPets();
      console.log('🐕 Mascotas cargadas:', petsList);
      console.log('📊 Cantidad de mascotas:', petsList.length);
      setPets(petsList);
      if (petsList.length > 0) {
        setPetId(petsList[0].id);
        console.log('✅ Mascota seleccionada:', petsList[0].name);
      } else {
        console.log('⚠️ No hay mascotas disponibles');
      }
    } catch (error) {
      console.error('❌ Error loading pets:', error);
    } finally {
      setIsLoadingPets(false);
    }
  };

  const validateForm = () => {
    if (pets.length === 0) {
      Alert.alert('Error', 'Debes registrar una mascota primero');
      return false;
    }
    if (!petId) {
      Alert.alert('Error', 'Selecciona una mascota');
      return false;
    }
    if (!location.trim()) {
      Alert.alert('Error', 'La ubicación es requerida');
      return false;
    }
    if (!description.trim()) {
      Alert.alert('Error', 'La descripción es requerida');
      return false;
    }
    return true;
  };

  const handleSubmit = async () => {
    if (!validateForm()) return;

    setIsLoading(true);
    try {
      await apiService.createAlert({
        petId,
        type,
        location: location.trim(),
        description: description.trim(),
      });
      
      Alert.alert(
        'Éxito',
        'Alerta creada correctamente',
        [
          {
            text: 'OK',
            onPress: () => router.push('/(tabs)/alerts'),
          },
        ]
      );
    } catch (error: any) {
      Alert.alert(
        'Error',
        error.response?.data?.message || 'Error al crear la alerta'
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <CustomHeader />
      
      <KeyboardAvoidingView
        style={styles.keyboardContainer}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <ScrollView 
          style={styles.scrollView}
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          <View style={styles.header}>
            <Text style={[styles.title, { color: colors.text }]}>Crear Alerta</Text>
            <Text style={[styles.subtitle, { color: colors.placeholder }]}>
              Reporta una mascota perdida o encontrada
            </Text>
          </View>

          <View style={[styles.form, { backgroundColor: colors.card }]}>
            <View style={styles.inputContainer}>
              <Text style={[styles.label, { color: colors.text }]}>Tipo de Alerta</Text>
              <View style={[styles.pickerContainer, { backgroundColor: colors.background, borderColor: colors.border }]}>
                <Picker
                  selectedValue={type}
                  onValueChange={(value) => setType(value)}
                  style={[styles.picker, { color: '#1f2937' }]}
                  itemStyle={{ color: '#1f2937' }}
                  dropdownIconColor={colors.text}
                >
                  <Picker.Item label="Mascota Perdida" value="LOST" color="#1f2937" />
                  <Picker.Item label="Mascota Encontrada" value="FOUND" color="#1f2937" />
                </Picker>
              </View>
            </View>

            <View style={styles.inputContainer}>
              <Text style={[styles.label, { color: colors.text }]}>Mascota</Text>
              {isLoadingPets ? (
                <View style={[styles.loadingContainer, { backgroundColor: colors.background, borderColor: colors.border }]}>
                  <Text style={[styles.loadingText, { color: colors.text }]}>
                    Cargando mascotas...
                  </Text>
                </View>
              ) : pets.length === 0 ? (
                <View style={[styles.noPetsContainer, { backgroundColor: colors.background, borderColor: colors.border }]}>
                  <Text style={[styles.noPetsText, { color: colors.text }]}>
                    No tienes mascotas registradas
                  </Text>
                  <TouchableOpacity
                    style={[styles.registerPetButton, { backgroundColor: colors.primary }]}
                    onPress={() => router.push('/(tabs)/pet-register')}
                  >
                    <Text style={styles.registerPetButtonText}>Registrar Mascota</Text>
                  </TouchableOpacity>
                </View>
              ) : (
                <View style={[
                  styles.pickerContainer, 
                  { 
                    backgroundColor: colors.background, 
                    borderColor: colors.border
                  }
                ]}>
                  <Picker
                    selectedValue={petId}
                    onValueChange={(value) => setPetId(value)}
                    style={[styles.picker, { color: '#1f2937' }]}
                    itemStyle={{ color: '#1f2937' }}
                    dropdownIconColor={colors.text}
                  >
                    {pets.map((pet) => (
                      <Picker.Item
                        key={pet.id}
                        label={pet.name}
                        value={pet.id}
                        color="#1f2937"
                      />
                    ))}
                  </Picker>
                </View>
              )}
            </View>

            <View style={styles.inputContainer}>
              <Text style={[styles.label, { color: colors.text }]}>Ubicación</Text>
              <TextInput
                style={[styles.input, { backgroundColor: colors.background, borderColor: colors.border, color: colors.text }]}
                value={location}
                onChangeText={setLocation}
                placeholder="Ingresa la ubicación"
                placeholderTextColor={colors.placeholder}
                autoCapitalize="words"
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={[styles.label, { color: colors.text }]}>Descripción</Text>
              <TextInput
                style={[styles.input, styles.textArea, { backgroundColor: colors.background, borderColor: colors.border, color: colors.text }]}
                value={description}
                onChangeText={setDescription}
                placeholder="Describe los detalles de la alerta..."
                placeholderTextColor={colors.placeholder}
                multiline
                numberOfLines={4}
                textAlignVertical="top"
              />
            </View>

            <TouchableOpacity
              style={[
                styles.button,
                type === 'LOST' ? styles.lostButton : styles.foundButton,
                { backgroundColor: type === 'LOST' ? colors.danger : colors.success },
                isLoading && styles.buttonDisabled,
              ]}
              onPress={handleSubmit}
              disabled={isLoading}
            >
              <Text style={styles.buttonText}>
                {isLoading
                  ? 'Creando alerta...'
                  : type === 'LOST'
                  ? 'Reportar Mascota Perdida'
                  : 'Reportar Mascota Encontrada'}
              </Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  keyboardContainer: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    padding: 20,
    paddingBottom: 80, // Reducido para menos espacio abajo
  },
  header: {
    alignItems: 'center',
    marginBottom: 30,
    marginTop: 20, // Aumentado para evitar la barra de estado
    paddingTop: 30, // Agregar padding adicional
  },
  title: {
    fontSize: 28, // Aumentado para mejor jerarquía visual
    fontWeight: 'bold',
    marginBottom: 12, // Aumentado el espaciado
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
    lineHeight: 22,
    opacity: 0.8, // Reducir opacidad para mejor jerarquía
  },
  form: {
    borderRadius: 12,
    padding: 24,
    marginTop: 10, // Agregar margen superior
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 5,
  },
  inputContainer: {
    marginBottom: 24, // Aumentado para mejor separación
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  textArea: {
    height: 100,
    paddingTop: 12,
  },
  pickerContainer: {
    borderWidth: 1,
    borderRadius: 8,
  },
  picker: {
    height: 50,
    color: '#1f2937', // Color oscuro fijo para mejor contraste
  },
  button: {
    borderRadius: 8,
    padding: 16,
    alignItems: 'center',
    marginTop: 10,
  },
  lostButton: {
    backgroundColor: '#e74c3c',
  },
  foundButton: {
    backgroundColor: '#27ae60',
  },
  buttonDisabled: {
    backgroundColor: '#bdc3c7',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  scanInfo: {
    borderRadius: 8,
    padding: 10,
    marginTop: 10,
    alignItems: 'center',
  },
  scanInfoText: {
    fontSize: 14,
    fontWeight: '600',
  },
  scanNote: {
    fontSize: 12,
    marginTop: 5,
    textAlign: 'center',
  },
  loadingContainer: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 20,
    alignItems: 'center',
  },
  loadingText: {
    fontSize: 16,
    textAlign: 'center',
  },
  noPetsContainer: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 20,
    alignItems: 'center',
  },
  noPetsText: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 15,
  },
  registerPetButton: {
    borderRadius: 8,
    padding: 12,
    alignItems: 'center',
  },
  registerPetButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
}); 