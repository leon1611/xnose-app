// Componente de encabezado personalizado para la aplicación
import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Image,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import { useAuth } from '../contexts/AuthContext';

interface CustomHeaderProps {
  title?: string;
  showUserInfo?: boolean;
  onBackPress?: () => void;
}

export default function CustomHeader({ title, showUserInfo = true, onBackPress }: CustomHeaderProps) {
  const { user } = useAuth();

  return (
    <LinearGradient
      colors={['#20B2AA', '#48D1CC']}
      style={styles.header}
    >
      <View style={styles.headerContent}>
        {/* Logo y título */}
        <View style={styles.logoSection}>
          {onBackPress && (
            <TouchableOpacity onPress={onBackPress} style={styles.backButton}>
              <FontAwesome name="arrow-left" size={20} color="white" />
            </TouchableOpacity>
          )}
          <View style={styles.logoContainer}>
            <Image 
              source={require('../assets/images/name-preview.png')}
              style={styles.logoImage}
              resizeMode="contain"
            />
          </View>
        </View>

        {/* Información del usuario */}
        {showUserInfo && (
          <View style={styles.userSection}>
            <Text style={styles.userLabel}>Usuario ID</Text>
            <View style={styles.userInfo}>
              <Text style={styles.userName}>{user?.username || 'Usuario'}</Text>
              <FontAwesome name="chevron-down" size={12} color="white" />
            </View>
          </View>
        )}
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  header: {
    paddingTop: 25, // Reducido de 40 a 25
    paddingBottom: 5, // Reducido de 10 a 5
  },
  headerContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 10, // Reducido de 15 a 10
  },
  logoSection: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  backButton: {
    marginRight: 10, // Reducido de 15 a 10
    padding: 3, // Reducido de 5 a 3
  },
  logoContainer: {
    marginRight: 8, // Reducido de 10 a 8
  },
  logoImage: {
    width: 50, // Reducido de 65 a 50
    height: 50, // Reducido de 65 a 50
  },
  userSection: {
    alignItems: 'flex-end',
  },
  userLabel: {
    fontSize: 10, // Reducido de 12 a 10
    color: 'rgba(255, 255, 255, 0.8)',
    marginBottom: 1, // Reducido de 2 a 1
  },
  userInfo: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  userName: {
    fontSize: 12, // Reducido de 14 a 12
    color: 'white',
    fontWeight: '500',
    marginRight: 3, // Reducido de 5 a 3
  },
}); 