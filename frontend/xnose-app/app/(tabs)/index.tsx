import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  Dimensions,
  Image,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../../contexts/AuthContext';
import { useTheme } from '../../contexts/ThemeContext';
import Colors from '../../constants/Colors';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import CustomHeader from '../../components/CustomHeader';

const { width, height } = Dimensions.get('window');

export default function DashboardScreen() {
  const { user, logout } = useAuth();
  const { theme } = useTheme();
  const router = useRouter();
  const colors = Colors[theme];

  const handleLogout = async () => {
    await logout();
    router.replace('/(auth)/login');
  };

  const menuItems = [
    {
      title: 'Mis Mascotas',
      icon: 'heart',
      route: '/(tabs)/pets' as any,
      color: colors.menuGreen,
    },
    {
      title: 'Escanear',
      icon: 'search',
      route: '/(tabs)/scan' as any,
      color: colors.menuBlue,
    },
    {
      title: 'Registrar Propietario',
      icon: 'user-plus',
      route: '/(tabs)/owner-form' as any,
      color: colors.menuOrange,
    },
    {
      title: 'Registrar Mascota',
      icon: 'plus-circle',
      route: '/(tabs)/pet-register' as any,
      color: colors.menuPurple,
    },
    {
      title: 'Alertas',
      icon: 'exclamation-triangle',
      route: '/(tabs)/alerts' as any,
      color: colors.menuRed,
    },
    {
      title: 'Configuración',
      icon: 'cog',
      route: '/(tabs)/settings' as any,
      color: colors.menuGray,
    },
  ];

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      {/* Header personalizado */}
      <CustomHeader />

      <ScrollView 
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.welcomeSection}>
          <Text style={[styles.welcomeText, { color: colors.text }]}>¡Bienvenido a X-NOSE!</Text>
        </View>

        <Text style={[styles.sectionTitle, { color: colors.text }]}>¿Qué quieres hacer hoy?</Text>
        
        <View style={styles.menuGrid}>
          {menuItems.map((item, index) => (
            <TouchableOpacity
              key={index}
              style={[styles.menuItem, { backgroundColor: colors.card }]}
              onPress={() => router.push(item.route)}
            >
              <View style={[styles.iconContainer, { backgroundColor: item.color }]}>
                <FontAwesome name={item.icon as any} size={24} color="white" />
              </View>
              <Text style={[styles.menuTitle, { color: colors.text }]}>{item.title}</Text>
            </TouchableOpacity>
          ))}
        </View>

        {/* Botón de logout */}
        <TouchableOpacity 
          style={[styles.logoutButton, { backgroundColor: colors.danger }]} 
          onPress={handleLogout}
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
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 40,
  },
  welcomeSection: {
    alignItems: 'center',
    marginBottom: 30,
    paddingTop: 10,
  },
  welcomeText: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 24,
    textAlign: 'center',
  },
  menuGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    gap: 16,
    marginBottom: 30,
  },
  menuItem: {
    width: (width - 60) / 2,
    backgroundColor: 'white',
    borderRadius: 16,
    padding: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 5,
    minHeight: 140,
  },
  iconContainer: {
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  menuTitle: {
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
    marginBottom: 4,
  },
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 25,
    alignSelf: 'center',
    gap: 8,
  },
  logoutButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});
