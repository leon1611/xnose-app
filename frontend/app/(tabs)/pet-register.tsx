import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  ScrollView,
  Image,
  Platform,
  SafeAreaView,
} from 'react-native';
import { useRouter, useFocusEffect } from 'expo-router';
import * as ImagePicker from 'expo-image-picker';
import { Picker } from '@react-native-picker/picker';
import { apiService } from '../../services/api';
import { useTheme } from '../../contexts/ThemeContext';
import Colors from '../../constants/Colors';
import CustomHeader from '../../components/CustomHeader';

export default function PetRegisterScreen() {
  const [name, setName] = useState('');
  const [breed, setBreed] = useState('');
  const [age, setAge] = useState('');
  const [sex, setSex] = useState<'MALE' | 'FEMALE'>('MALE');
  const [profileImage, setProfileImage] = useState<string | null>(null);
  const [noseImage, setNoseImage] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [owners, setOwners] = useState<any[]>([]);
  const [selectedOwnerId, setSelectedOwnerId] = useState<string>('');
  const router = useRouter();
  const { theme } = useTheme();
  const colors = Colors[theme];

  useEffect(() => {
    loadOwners();
    requestPermissions();
  }, []);

  // Refrescar propietarios cuando se enfoque la pantalla
  useFocusEffect(
    React.useCallback(() => {
      console.log('🔄 Pantalla enfocada, refrescando propietarios...');
      loadOwners();
    }, [])
  );

  const requestPermissions = async () => {
    if (Platform.OS !== 'web') {
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permisos requeridos', 'Se necesitan permisos para acceder a la galería');
      }
    }
  };

  const loadOwners = async () => {
    try {
      console.log('🔄 Cargando propietarios...');
      const ownersList = await apiService.getOwners();
      console.log('📋 Propietarios cargados:', ownersList);
      console.log('👤 Cantidad de propietarios:', ownersList.length);
      setOwners(ownersList);
      if (ownersList.length > 0) {
        setSelectedOwnerId(ownersList[0].id);
        console.log('✅ Propietario seleccionado:', ownersList[0].name);
      } else {
        console.log('⚠️ No hay propietarios disponibles');
      }
    } catch (error) {
      console.error('❌ Error loading owners:', error);
    }
  };

  const pickImage = async (type: 'profile' | 'nose') => {
    try {
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.8,
      });

      if (result.canceled) {
        // El usuario canceló, no mostrar error
        return;
      }

      if (result.assets && result.assets[0]) {
        if (type === 'profile') {
          setProfileImage(result.assets[0].uri);
        } else {
          setNoseImage(result.assets[0].uri);
        }
      }
    } catch (error) {
      console.error('Error al seleccionar la imagen:', error);
      Alert.alert('Error', 'Ocurrió un problema al seleccionar la imagen. Revisa los permisos de la app.');
    }
  };

  const validateForm = () => {
    if (!name.trim()) {
      Alert.alert('Error', 'El nombre de la mascota es requerido');
      return false;
    }
    if (!breed.trim()) {
      Alert.alert('Error', 'La raza es requerida');
      return false;
    }
    if (!age.trim()) {
      Alert.alert('Error', 'La edad es requerida');
      return false;
    }
    if (isNaN(Number(age)) || Number(age) <= 0) {
      Alert.alert('Error', 'Ingresa una edad válida');
      return false;
    }
    if (owners.length === 0) {
      Alert.alert('Error', 'Debes registrar un propietario primero');
      return false;
    }
    if (!selectedOwnerId) {
      Alert.alert('Error', 'Selecciona un propietario');
      return false;
    }
    if (!profileImage) {
      Alert.alert('Error', 'Selecciona una foto de perfil');
      return false;
    }
    if (!noseImage) {
      Alert.alert('Error', 'Selecciona una foto de la nariz');
      return false;
    }
    return true;
  };

  const createFormData = () => {
    const formData = new FormData();
    formData.append('name', name.trim());
    formData.append('breed', breed.trim());
    formData.append('age', age);
    formData.append('sex', sex);
    formData.append('ownerId', selectedOwnerId);

    if (profileImage) {
      const profileImageFile = {
        uri: profileImage,
        type: 'image/jpeg',
        name: 'profile.jpg',
      } as any;
      formData.append('profileImage', profileImageFile);
    }

    if (noseImage) {
      const noseImageFile = {
        uri: noseImage,
        type: 'image/jpeg',
        name: 'nose.jpg',
      } as any;
      formData.append('noseImage', noseImageFile);
    }

    return formData;
  };

  const clearForm = () => {
    setName('');
    setBreed('');
    setAge('');
    setSex('MALE');
    setProfileImage(null);
    setNoseImage(null);
    if (owners.length > 0) {
      setSelectedOwnerId(owners[0].id);
    }
  };

  const handleSubmit = async () => {
    if (!validateForm()) return;

    setIsLoading(true);
    try {
      const formData = createFormData();
      await apiService.createPet(formData);
      
      // Limpiar el formulario después de crear exitosamente
      clearForm();
      
      Alert.alert(
        'Éxito',
        'Mascota registrada correctamente',
        [
          {
            text: 'OK',
            onPress: () => router.push('/'),
          },
        ]
      );
    } catch (error: any) {
      Alert.alert(
        'Error',
        error.response?.data?.message || 'Error al registrar la mascota'
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <CustomHeader />
      
      <ScrollView 
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={[styles.header, { backgroundColor: colors.card, borderBottomColor: colors.border }]}>
          <Text style={[styles.title, { color: colors.text }]}>Registrar Mascota</Text>
          <Text style={[styles.subtitle, { color: colors.placeholder }]}>Información de la mascota</Text>
        </View>

        <View style={styles.form}>
          <View style={styles.inputContainer}>
            <Text style={[styles.label, { color: colors.text }]}>Nombre de la Mascota</Text>
            <TextInput
              style={[styles.input, { backgroundColor: colors.background, borderColor: colors.border, color: colors.text }]}
              value={name}
              onChangeText={setName}
              placeholder="Ingresa el nombre"
              placeholderTextColor={colors.placeholder}
              autoCapitalize="words"
            />
          </View>

          <View style={styles.inputContainer}>
            <Text style={[styles.label, { color: colors.text }]}>Raza</Text>
            <TextInput
              style={[styles.input, { backgroundColor: colors.background, borderColor: colors.border, color: colors.text }]}
              value={breed}
              onChangeText={setBreed}
              placeholder="Ingresa la raza"
              placeholderTextColor={colors.placeholder}
              autoCapitalize="words"
            />
          </View>

          <View style={styles.inputContainer}>
            <Text style={[styles.label, { color: colors.text }]}>Edad (años)</Text>
            <TextInput
              style={[styles.input, { backgroundColor: colors.background, borderColor: colors.border, color: colors.text }]}
              value={age}
              onChangeText={setAge}
              placeholder="Ingresa la edad"
              placeholderTextColor={colors.placeholder}
              keyboardType="numeric"
            />
          </View>

          <View style={styles.inputContainer}>
            <Text style={[styles.label, { color: colors.text }]}>Sexo</Text>
            <View style={[styles.pickerContainer, { backgroundColor: colors.background, borderColor: colors.border }]}>
              <Picker
                selectedValue={sex}
                onValueChange={(value) => setSex(value)}
                style={[styles.picker, { color: '#1f2937' }]}
                itemStyle={{ color: '#1f2937' }}
                dropdownIconColor={colors.text}
              >
                <Picker.Item label="Macho" value="MALE" color="#1f2937" />
                <Picker.Item label="Hembra" value="FEMALE" color="#1f2937" />
              </Picker>
            </View>
          </View>

          <View style={styles.inputContainer}>
            <Text style={[styles.label, { color: colors.text }]}>Propietario</Text>
            {owners.length === 0 ? (
              <View style={[styles.noOwnersContainer, { backgroundColor: colors.background, borderColor: colors.border }]}>
                <Text style={[styles.noOwnersText, { color: colors.text }]}>
                  No tienes propietarios registrados
                </Text>
                <TouchableOpacity
                  style={[styles.registerOwnerButton, { backgroundColor: colors.primary }]}
                  onPress={() => router.push('/(tabs)/owner-form')}
                >
                  <Text style={styles.registerOwnerButtonText}>Registrar Propietario</Text>
                </TouchableOpacity>
              </View>
            ) : (
              <View style={[styles.pickerContainer, { backgroundColor: colors.background, borderColor: colors.border }]}>
                <Picker
                  selectedValue={selectedOwnerId}
                  onValueChange={(value) => setSelectedOwnerId(value)}
                  style={[styles.picker, { color: '#1f2937' }]}
                  itemStyle={{ color: '#1f2937' }}
                  dropdownIconColor={colors.text}
                >
                  {owners.map((owner) => (
                    <Picker.Item
                      key={owner.id}
                      label={owner.name}
                      value={owner.id}
                      color="#1f2937"
                    />
                  ))}
                </Picker>
              </View>
            )}
          </View>

          <View style={styles.imageSection}>
            <Text style={[styles.sectionTitle, { color: colors.text }]}>Fotos de la Mascota</Text>
            
            <View style={styles.imageContainer}>
              <Text style={[styles.imageLabel, { color: colors.text }]}>Foto de Perfil</Text>
              <TouchableOpacity
                style={[styles.imageButton, { backgroundColor: colors.background, borderColor: colors.border }]}
                onPress={() => pickImage('profile')}
              >
                {profileImage ? (
                  <Image source={{ uri: profileImage }} style={styles.selectedImage} />
                ) : (
                  <Text style={[styles.imageButtonText, { color: colors.placeholder }]}>Seleccionar Foto</Text>
                )}
              </TouchableOpacity>
            </View>

            <View style={styles.imageContainer}>
              <Text style={[styles.imageLabel, { color: colors.text }]}>Foto de la Nariz</Text>
              <TouchableOpacity
                style={[styles.imageButton, { backgroundColor: colors.background, borderColor: colors.border }]}
                onPress={() => pickImage('nose')}
              >
                {noseImage ? (
                  <Image source={{ uri: noseImage }} style={styles.selectedImage} />
                ) : (
                  <Text style={[styles.imageButtonText, { color: colors.placeholder }]}>Seleccionar Foto</Text>
                )}
              </TouchableOpacity>
            </View>
          </View>

          <TouchableOpacity
            style={[styles.button, { backgroundColor: colors.primary }, isLoading && styles.buttonDisabled]}
            onPress={handleSubmit}
            disabled={isLoading}
          >
            <Text style={styles.buttonText}>
              {isLoading ? 'Registrando...' : 'Registrar Mascota'}
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: 120, // Aumentado para que el contenido no se tape
  },
  header: {
    alignItems: 'center',
    padding: 20,
    paddingTop: 50, // Aumentado para evitar la barra de estado
    paddingBottom: 20,
    borderBottomWidth: 1,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
  },
  form: {
    padding: 20,
  },
  inputContainer: {
    marginBottom: 20,
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
  pickerContainer: {
    borderWidth: 1,
    borderRadius: 8,
  },
  picker: {
    height: 50,
    color: '#1f2937', // Color oscuro fijo para mejor contraste
  },
  imageSection: {
    marginTop: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 15,
  },
  imageContainer: {
    marginBottom: 20,
  },
  imageLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  imageButton: {
    borderWidth: 2,
    borderStyle: 'dashed',
    borderRadius: 8,
    padding: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  imageButtonText: {
    color: '#7f8c8d',
    fontSize: 16,
  },
  selectedImage: {
    width: 100,
    height: 100,
    borderRadius: 8,
  },
  button: {
    borderRadius: 8,
    padding: 16,
    alignItems: 'center',
    marginTop: 20,
  },
  buttonDisabled: {
    backgroundColor: '#bdc3c7',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  noOwnersContainer: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 20,
    alignItems: 'center',
  },
  noOwnersText: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 15,
  },
  registerOwnerButton: {
    borderRadius: 8,
    padding: 12,
    alignItems: 'center',
  },
  registerOwnerButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
}); 