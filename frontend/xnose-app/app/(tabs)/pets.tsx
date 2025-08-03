import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  RefreshControl,
  Alert,
  Image,
  SafeAreaView,
} from 'react-native';
import { useRouter, useFocusEffect } from 'expo-router';
import { apiService } from '../../services/api';
import { useTheme } from '../../contexts/ThemeContext';
import Colors from '../../constants/Colors';
import CustomHeader from '../../components/CustomHeader';

export default function PetsScreen() {
  const [pets, setPets] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [imageErrors, setImageErrors] = useState<Set<string>>(new Set());
  const router = useRouter();
  const { theme } = useTheme();
  const colors = Colors[theme];

  useEffect(() => {
    loadPets();
  }, []);

  // Refrescar mascotas cuando se enfoque la pantalla
  useFocusEffect(
    React.useCallback(() => {
      console.log('🔄 Pantalla de mascotas enfocada, refrescando...');
      loadPets();
    }, [])
  );

  const loadPets = async () => {
    setIsLoading(true);
    try {
      const petsList = await apiService.getPets();
      // Ordenar por fecha de creación (más recientes primero)
      const sortedPets = petsList.sort((a: any, b: any) => 
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
      );
      setPets(sortedPets);
    } catch (error) {
      Alert.alert('Error', 'Error al cargar las mascotas');
    } finally {
      setIsLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadPets();
    setRefreshing(false);
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  const getSexIcon = (sex: string) => {
    return sex === 'MALE' ? '♂️' : '♀️';
  };

  const renderPet = ({ item }: { item: any }) => {
    // Determinar si mostrar imagen o placeholder
    const hasValidImage = item.profileImageUrl && 
                         !imageErrors.has(item.profileImageUrl) && 
                         item.profileImageUrl !== 'null' &&
                         item.profileImageUrl.trim() !== '' &&
                         item.profileImageUrl.startsWith('http'); // Solo verificar que sea una URL válida
    
    return (
      <View style={[styles.petCard, { backgroundColor: colors.card }]}>
        <View style={styles.petHeaderRow}>
          {/* Imagen de la mascota a la izquierda */}
          {hasValidImage ? (
            <Image
              source={{ 
                uri: item.profileImageUrl,
                headers: {
                  'Accept': 'image/*',
                }
              }}
              style={styles.petImage}
              resizeMode="cover"
              onError={() => {
                console.log('Error loading image:', item.profileImageUrl);
                setImageErrors(prev => new Set(prev).add(item.profileImageUrl));
              }}
              onLoad={() => console.log('Image loaded successfully:', item.profileImageUrl)}
            />
          ) : (
            <View style={[styles.petImage, styles.defaultImage]}>
              <Image 
                source={require('../../assets/images/xnose-logo.png')}
                style={styles.defaultImageLogo}
                resizeMode="contain"
              />
            </View>
          )}
          
          {/* Info principal al centro */}
          <View style={styles.petMainInfo}>
            <Text style={[styles.petName, { color: colors.text }]}>{item.name}</Text>
            <Text style={[styles.petBreed, { color: colors.text }]}>{item.breed}</Text>
            <Text style={[styles.petDetails, { color: colors.text }]}>
              {item.age} años • {getSexIcon(item.sex)}
            </Text>
            <Text style={[styles.petDate, { color: colors.placeholder }]}>
              Registrado: {formatDate(item.createdAt)}
            </Text>
          </View>
        </View>

        <View style={styles.petActions}>
          <TouchableOpacity
            style={[styles.actionButton, { backgroundColor: colors.primary }]}
            onPress={() => {
              Alert.alert('Detalles', `ID: ${item.id}\nPropietario: ${item.ownerId}`);
            }}
          >
            <Text style={styles.actionButtonText}>Ver Detalles</Text>
          </TouchableOpacity>
          
          <TouchableOpacity
            style={[styles.actionButton, styles.alertButton, { backgroundColor: colors.danger }]}
            onPress={() => router.push('/(tabs)/alert-create')}
          >
            <Text style={styles.actionButtonText}>Crear Alerta</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  };

  const EmptyState = () => (
    <View style={styles.emptyState}>
      <Text style={styles.emptyStateIcon}>🐕</Text>
      <Text style={[styles.emptyStateTitle, { color: colors.text }]}>No hay mascotas registradas</Text>
      <Text style={[styles.emptyStateText, { color: colors.placeholder }]}>
        Registra tu primera mascota para comenzar
      </Text>
    </View>
  );

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <CustomHeader />

      <FlatList
        data={pets}
        renderItem={renderPet}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={EmptyState}
        showsVerticalScrollIndicator={false}
      />

      {/* Botón flotante para agregar mascota */}
      <View style={styles.bottomButtonContainer}>
        <TouchableOpacity
          style={[styles.bigButton, { backgroundColor: colors.primary }]}
          onPress={() => router.push('/(tabs)/pet-register')}
        >
          <Text style={styles.bigButtonText}>+ Nueva Mascota</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  listContainer: {
    padding: 20,
    paddingTop: 0,
    paddingBottom: 100,
  },
  petCard: {
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 2,
  },
  petHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  petImage: {
    width: 80,
    height: 80,
    borderRadius: 40,
    marginRight: 16,
  },
  defaultImage: {
    backgroundColor: '#20B2AA',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#48D1CC',
  },
  defaultImageLogo: {
    width: 50,
    height: 50,
  },
  defaultImageText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
  },
  petMainInfo: {
    flex: 1,
  },
  petName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2c3e50',
    marginBottom: 4,
  },
  petBreed: {
    fontSize: 16,
    color: '#7f8c8d',
    marginBottom: 4,
  },
  petDetails: {
    fontSize: 14,
    color: '#34495e',
    marginBottom: 4,
  },
  petDate: {
    fontSize: 12,
    color: '#95a5a6',
  },
  petActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  actionButton: {
    flex: 1,
    backgroundColor: '#3498db',
    padding: 12,
    borderRadius: 8,
    marginHorizontal: 4,
    alignItems: 'center',
  },
  alertButton: {
    backgroundColor: '#e74c3c',
  },
  actionButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  emptyState: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 60,
  },
  emptyStateIcon: {
    fontSize: 64,
    marginBottom: 16,
  },
  emptyStateTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  emptyStateText: {
    fontSize: 16,
    textAlign: 'center',
    lineHeight: 24,
  },
  bottomButtonContainer: {
    position: 'absolute',
    bottom: 20,
    left: 20,
    right: 20,
  },
  bigButton: {
    backgroundColor: '#3498db',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
  bigButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  logoutButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
}); 