import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Switch,
  TouchableOpacity,
  ScrollView,
  Alert,
  StatusBar,
  SafeAreaView,
  Image,
} from 'react-native';
import { useRouter } from 'expo-router';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import Colors from '@/constants/Colors';
import { useTheme } from '@/contexts/ThemeContext';
import { useAuth } from '@/contexts/AuthContext';
import CustomHeader from '@/components/CustomHeader';

export default function SettingsScreen() {
  const { theme, toggleTheme } = useTheme();
  const colors = Colors[theme];
  const [servicesStatus, setServicesStatus] = useState({
    gateway: false,
    pet: false,
    owner: false,
    alert: false,
  });
  const router = useRouter();

  useEffect(() => {
    checkServicesStatus();
  }, []);

  const checkServicesStatus = async () => {
    // Simular verificación de estado de servicios
    // En una implementación real, aquí se harían pings a los servicios
    setServicesStatus({
      gateway: true,
      pet: true,
      owner: true,
      alert: true,
    });
  };

  const getServiceStatusColor = (status: boolean) => {
    return status ? '#22c55e' : '#ef4444';
  };

  const getServiceStatusText = (status: boolean) => {
    return status ? 'Conectado' : 'Desconectado';
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <StatusBar barStyle={theme === 'dark' ? 'light-content' : 'dark-content'} backgroundColor={colors.primary} />
      
      {/* Header personalizado */}
      <CustomHeader onBackPress={() => router.back()} />

      <ScrollView 
        style={styles.content}
        contentContainerStyle={styles.contentContainer}
        showsVerticalScrollIndicator={false}
      >
        {/* Apariencia */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: colors.text }]}>APARIENCIA</Text>
          
          <View style={[styles.settingItem, { backgroundColor: colors.card }]}>
            <View style={styles.settingLeft}>
              <FontAwesome name="sun-o" size={20} color={colors.primary} />
              <Text style={[styles.settingText, { color: colors.text }]}>Modo Claro</Text>
            </View>
            <Switch
              value={theme === 'light'}
              onValueChange={toggleTheme}
              trackColor={{ false: colors.border, true: colors.primary }}
              thumbColor="white"
            />
          </View>
        </View>

        {/* Estado de Servicios */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: colors.text }]}>ESTADO DE SERVICIOS</Text>
          
          <View style={[styles.settingItem, { backgroundColor: colors.card }]}>
            <View style={styles.settingLeft}>
              <FontAwesome name="server" size={20} color={getServiceStatusColor(servicesStatus.gateway)} />
              <Text style={[styles.settingText, { color: colors.text }]}>API Gateway</Text>
            </View>
            <Text style={[styles.statusText, { color: getServiceStatusColor(servicesStatus.gateway) }]}>
              {getServiceStatusText(servicesStatus.gateway)}
            </Text>
          </View>

          <View style={[styles.settingItem, { backgroundColor: colors.card }]}>
            <View style={styles.settingLeft}>
              <FontAwesome name="paw" size={20} color={getServiceStatusColor(servicesStatus.pet)} />
              <Text style={[styles.settingText, { color: colors.text }]}>Pet Service</Text>
            </View>
            <Text style={[styles.statusText, { color: getServiceStatusColor(servicesStatus.pet) }]}>
              {getServiceStatusText(servicesStatus.pet)}
            </Text>
          </View>

          <View style={[styles.settingItem, { backgroundColor: colors.card }]}>
            <View style={styles.settingLeft}>
              <FontAwesome name="user" size={20} color={getServiceStatusColor(servicesStatus.owner)} />
              <Text style={[styles.settingText, { color: colors.text }]}>Owner Service</Text>
            </View>
            <Text style={[styles.statusText, { color: getServiceStatusColor(servicesStatus.owner) }]}>
              {getServiceStatusText(servicesStatus.owner)}
            </Text>
          </View>

          <View style={[styles.settingItem, { backgroundColor: colors.card }]}>
            <View style={styles.settingLeft}>
              <FontAwesome name="bell" size={20} color={getServiceStatusColor(servicesStatus.alert)} />
              <Text style={[styles.settingText, { color: colors.text }]}>Alert Service</Text>
            </View>
            <Text style={[styles.statusText, { color: getServiceStatusColor(servicesStatus.alert) }]}>
              {getServiceStatusText(servicesStatus.alert)}
            </Text>
          </View>
        </View>

        {/* Información de la App */}
        <View style={styles.section}>
          <Text style={[styles.sectionTitle, { color: colors.text }]}>INFORMACIÓN</Text>
          
          <View style={[styles.settingItem, { backgroundColor: colors.card }]}>
            <View style={styles.settingLeft}>
              <FontAwesome name="info-circle" size={20} color={colors.primary} />
              <Text style={[styles.settingText, { color: colors.text }]}>Versión</Text>
            </View>
            <Text style={[styles.settingText, { color: colors.text }]}>1.0.0</Text>
          </View>

          <View style={[styles.settingItem, { backgroundColor: colors.card }]}>
            <View style={styles.settingLeft}>
              <FontAwesome name="code" size={20} color={colors.primary} />
              <Text style={[styles.settingText, { color: colors.text }]}>Desarrollado por</Text>
            </View>
            <Text style={[styles.settingText, { color: colors.text }]}>PetNow Team</Text>
          </View>
        </View>

        {/* Botón de Cerrar Sesión */}
        <TouchableOpacity 
          style={[styles.logoutButton, { backgroundColor: colors.danger }]} 
          onPress={() => {
            Alert.alert(
              'Cerrar Sesión',
              '¿Estás seguro de que quieres cerrar sesión?',
              [
                { text: 'Cancelar', style: 'cancel' },
                { 
                  text: 'Cerrar Sesión', 
                  style: 'destructive',
                  onPress: () => router.replace('/(auth)/login')
                }
              ]
            );
          }}
        >
          <FontAwesome name="sign-out" size={16} color="white" />
          <Text style={styles.logoutButtonText}>Cerrar Sesión</Text>
        </TouchableOpacity>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: 20,
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 15,
    letterSpacing: 1,
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderRadius: 12,
    marginBottom: 8,
  },
  settingLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingText: {
    fontSize: 16,
    marginLeft: 12,
    fontWeight: '500',
  },
  statusText: {
    fontSize: 14,
    fontWeight: '600',
  },
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    borderRadius: 12,
    marginTop: 20,
  },
  logoutButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
    marginLeft: 8,
  },
}); 