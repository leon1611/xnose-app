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

export default function AlertsScreen() {
  const [alerts, setAlerts] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [imageErrors, setImageErrors] = useState<Set<string>>(new Set());
  const router = useRouter();
  const { theme } = useTheme();
  const colors = Colors[theme];

  useEffect(() => {
    loadAlerts();
  }, []);

  // Refrescar alertas cuando se enfoque la pantalla
  useFocusEffect(
    React.useCallback(() => {
      console.log('🔄 Pantalla de alertas enfocada, refrescando...');
      loadAlerts();
    }, [])
  );

  const loadAlerts = async () => {
    setIsLoading(true);
    try {
      const alertsList = await apiService.getAlerts();
      // Ordenar por fecha de creación (más recientes primero)
      const sortedAlerts = alertsList.sort((a: any, b: any) => 
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
      );
      setAlerts(sortedAlerts);
    } catch (error) {
      Alert.alert('Error', 'Error al cargar las alertas');
    } finally {
      setIsLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadAlerts();
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

  const getAlertColor = (type: string) => {
    return type === 'LOST' ? '#e74c3c' : '#27ae60';
  };

  const getAlertIcon = (type: string) => {
    return type === 'LOST' ? '🚨' : '✅';
  };

  const renderAlert = ({ item }: { item: any }) => {
    console.log('petName:', item.petName);
    
    // Determinar si mostrar imagen o placeholder
    const hasValidImage = item.petProfileImageUrl && 
                         !imageErrors.has(item.petProfileImageUrl) && 
                         item.petProfileImageUrl !== 'null' &&
                         item.petProfileImageUrl.trim() !== '' &&
                         item.petProfileImageUrl.startsWith('http'); // Solo verificar que sea una URL válida
    
    console.log('hasValidImage:', hasValidImage);
    console.log('imageErrors:', Array.from(imageErrors));
    
    return (
      <View style={[styles.alertCard, { backgroundColor: colors.card }]}>
        <View style={styles.alertHeaderRow}>
          {/* Icono de alerta a la izquierda */}
          <Text style={styles.alertIcon}>{getAlertIcon(item.type)}</Text>
          {/* Info principal al centro */}
          <View style={styles.alertMainInfo}>
            <Text style={[styles.alertType, { color: colors.text }]}>
              {item.type === 'LOST' ? 'Mascota Perdida' : 'Mascota Encontrada'}
            </Text>
            <Text style={[styles.alertDate, { color: colors.placeholder }]}>{formatDate(item.createdAt)}</Text>
            {item.petName && (
              <Text style={[styles.petName, { color: colors.text }]}>{item.petName}</Text>
            )}
          </View>
          {/* Imagen de la mascota a la derecha */}
          {hasValidImage ? (
            <Image
              source={{ 
                uri: item.petProfileImageUrl,
                headers: {
                  'Accept': 'image/*',
                }
              }}
              style={styles.petImage}
              resizeMode="cover"
              onError={(error) => {
                console.log('Error loading image:', item.petProfileImageUrl, error.nativeEvent.error);
                setImageErrors(prev => new Set(prev).add(item.petProfileImageUrl));
              }}
              onLoad={() => console.log('Image loaded successfully:', item.petProfileImageUrl)}
              onLoadStart={() => console.log('Image load started:', item.petProfileImageUrl)}
            />
          ) : (
            <View style={[styles.petImage, styles.defaultImage]}>
              <Text style={styles.defaultImageText}>
                {item.petName ? item.petName.charAt(0).toUpperCase() : '🐕'}
              </Text>
              {!item.petProfileImageUrl && (
                <Text style={styles.noImageText}>Sin foto</Text>
              )}
            </View>
          )}
        </View>

        <View style={styles.alertContent}>
          <Text style={[styles.alertLocation, { color: colors.text }]}>📍 {item.location}</Text>
          <Text style={[styles.alertDescription, { color: colors.text }]}>{item.description}</Text>
        </View>

        <View style={styles.alertActions}>
          <TouchableOpacity
            style={[styles.actionButton, { backgroundColor: colors.primary }]}
            onPress={() => {
              Alert.alert('Detalles', `ID de Mascota: ${item.petId}`);
            }}
          >
            <Text style={styles.actionButtonText}>Ver Detalles</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  };

  const EmptyState = () => (
    <View style={styles.emptyState}>
      <Text style={styles.emptyStateIcon}>📋</Text>
      <Text style={[styles.emptyStateTitle, { color: colors.text }]}>No hay alertas</Text>
      <Text style={[styles.emptyStateText, { color: colors.placeholder }]}>
        No se han reportado mascotas perdidas o encontradas
      </Text>
    </View>
  );

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <CustomHeader />

      <FlatList
        data={alerts}
        renderItem={renderAlert}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContainer}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
        ListEmptyComponent={EmptyState}
        showsVerticalScrollIndicator={false}
      />

      {/* Botón grande y centrado debajo de la lista */}
      <View style={styles.bottomButtonContainer}>
        <TouchableOpacity
          style={[styles.bigButton, { backgroundColor: colors.primary }]}
          onPress={() => router.push('/(tabs)/alert-create')}
        >
          <Text style={styles.bigButtonText}>+ Nueva Alerta</Text>
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
  alertCard: {
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
  alertHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  alertIcon: {
    fontSize: 24,
    marginRight: 12,
  },
  alertMainInfo: {
    flex: 1,
  },
  alertType: {
    fontSize: 16,
    fontWeight: '600',
    color: '#2c3e50',
  },
  alertDate: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 2,
  },
  petName: {
    fontSize: 14,
    fontWeight: '500',
    color: '#34495e',
    marginTop: 4,
  },
  petImage: {
    width: 60,
    height: 60,
    borderRadius: 30,
    marginLeft: 12,
  },
  defaultImage: {
    backgroundColor: '#3498db',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#2980b9',
  },
  defaultImageText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
  },
  noImageText: {
    fontSize: 8,
    color: 'white',
    marginTop: 2,
  },
  alertContent: {
    marginBottom: 12,
  },
  alertLocation: {
    fontSize: 14,
    color: '#2c3e50',
    marginBottom: 8,
  },
  alertDescription: {
    fontSize: 14,
    color: '#7f8c8d',
    lineHeight: 20,
  },
  alertActions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  actionButton: {
    backgroundColor: '#3498db',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
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