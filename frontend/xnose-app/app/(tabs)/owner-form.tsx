import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  SafeAreaView,
} from 'react-native';
import { useRouter } from 'expo-router';
import { apiService } from '../../services/api';
import { useAuth } from '../../contexts/AuthContext';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useTheme } from '../../contexts/ThemeContext';
import Colors from '../../constants/Colors';
import CustomHeader from '../../components/CustomHeader';

export default function OwnerFormScreen() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [address, setAddress] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();
  const { user } = useAuth();
  const { theme } = useTheme();
  const colors = Colors[theme];
  console.log('Usuario en contexto:', user);

  const validateEmail = (email: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const validateForm = () => {
    if (!name.trim()) {
      Alert.alert('Error', 'El nombre es requerido');
      return false;
    }
    if (!email.trim()) {
      Alert.alert('Error', 'El email es requerido');
      return false;
    }
    if (!validateEmail(email.trim())) {
      Alert.alert('Error', 'Ingresa un email válido');
      return false;
    }
    if (!phone.trim()) {
      Alert.alert('Error', 'El teléfono es requerido');
      return false;
    }
    if (!address.trim()) {
      Alert.alert('Error', 'La dirección es requerida');
      return false;
    }
    return true;
  };

  const handleSubmit = async () => {
    console.log('handleSubmit ejecutado');
    const token = await AsyncStorage.getItem('authToken');
    console.log('Token en AsyncStorage antes de registrar:', token);
    if (!validateForm()) return;

    setIsLoading(true);
    const ownerPayload = {
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      address: address.trim(),
    };
    console.log('Enviando petición de registro...', ownerPayload);
    try {
      const owner = await apiService.createOwner(ownerPayload);
      console.log('Respuesta del backend:', owner);
      Alert.alert(
        'Éxito',
        'Propietario registrado correctamente',
        [
          {
            text: 'OK',
            onPress: () => router.push('/(tabs)/pet-register'),
          },
        ]
      );
    } catch (error: any) {
      console.log('Error backend:', error.response?.data || error.message);
      let errorMsg = 'Error al registrar el propietario';
      if (error.response) {
        errorMsg = `(${error.response.status}) ${error.response.data?.message || JSON.stringify(error.response.data)}`;
      } else if (error.message) {
        errorMsg = error.message;
      }
      Alert.alert(
        'Error',
        errorMsg
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
          <View style={styles.header}>
            <Text style={[styles.title, { color: colors.text }]}>Registrar Propietario</Text>
            <Text style={[styles.subtitle, { color: colors.placeholder }]}>Información del dueño de la mascota</Text>
          </View>

          <View style={[styles.form, { backgroundColor: colors.card }]}>
            <View style={styles.inputContainer}>
              <Text style={[styles.label, { color: colors.text }]}>Nombre Completo</Text>
              <TextInput
                style={[styles.input, { backgroundColor: colors.background, borderColor: colors.border, color: colors.text }]}
                value={name}
                onChangeText={setName}
                placeholder="Ingresa el nombre completo"
                placeholderTextColor={colors.placeholder}
                autoCapitalize="words"
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={[styles.label, { color: colors.text }]}>Email</Text>
              <TextInput
                style={[styles.input, { backgroundColor: colors.background, borderColor: colors.border, color: colors.text }]}
                value={email}
                onChangeText={setEmail}
                placeholder="ejemplo@email.com"
                placeholderTextColor={colors.placeholder}
                keyboardType="email-address"
                autoCapitalize="none"
                autoCorrect={false}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={[styles.label, { color: colors.text }]}>Teléfono</Text>
              <TextInput
                style={[styles.input, { backgroundColor: colors.background, borderColor: colors.border, color: colors.text }]}
                value={phone}
                onChangeText={setPhone}
                placeholder="+1234567890"
                placeholderTextColor={colors.placeholder}
                keyboardType="phone-pad"
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={[styles.label, { color: colors.text }]}>Dirección</Text>
              <TextInput
                style={[styles.input, { backgroundColor: colors.background, borderColor: colors.border, color: colors.text }]}
                value={address}
                onChangeText={setAddress}
                placeholder="Ingresa la dirección"
                placeholderTextColor={colors.placeholder}
                autoCapitalize="words"
              />
            </View>

            <TouchableOpacity
              style={[styles.button, { backgroundColor: colors.primary }, isLoading && styles.buttonDisabled]}
              onPress={handleSubmit}
              disabled={isLoading}
            >
              <Text style={styles.buttonText}>
                {isLoading ? 'Registrando...' : 'Registrar Propietario'}
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
  keyboardContainer: {
    flex: 1,
  },
  scrollContainer: {
    flexGrow: 1,
    padding: 20,
    paddingBottom: 60, // Reducido para eliminar espacio excesivo abajo
  },
  header: {
    alignItems: 'center',
    marginBottom: 30,
    marginTop: 25, // Aumentado para bajar el título y evitar que choque arriba
  },
  title: {
    fontSize: 24, // Reducido de 28 a 24
    fontWeight: 'bold',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    textAlign: 'center',
  },
  form: {
    borderRadius: 12,
    padding: 24,
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
  button: {
    borderRadius: 8,
    padding: 16,
    alignItems: 'center',
    marginTop: 10,
  },
  buttonDisabled: {
    backgroundColor: '#bdc3c7',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    padding: 20,
    paddingBottom: 60, // Reducido para eliminar espacio excesivo abajo
  },
}); 