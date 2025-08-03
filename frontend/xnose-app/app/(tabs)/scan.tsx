// Pantalla de escaneo de huellas nasales de mascotas
import React, { useState } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Alert,
  Image,
  ActivityIndicator,
  SafeAreaView,
  ScrollView,
  Dimensions,
} from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { apiService } from '../../services/api';
import { useTheme } from '../../contexts/ThemeContext';
import Colors from '../../constants/Colors';
import { useRouter } from 'expo-router';
import CustomHeader from '../../components/CustomHeader';

const { width } = Dimensions.get('window');

export default function ScanScreen() {
  const [capturedImage, setCapturedImage] = useState<string | null>(null);
  const [isScanning, setIsScanning] = useState(false);
  const [scanResult, setScanResult] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [visualComparison, setVisualComparison] = useState<any>(null);
  const [isComparing, setIsComparing] = useState(false);
  const { theme } = useTheme();
  const colors = Colors[theme];
  const router = useRouter();

  const pickImage = async () => {
    try {
      setIsLoading(true);
      
      // Solicitar permisos
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert(
          'Permisos Requeridos',
          'Necesitamos acceso a tu galería para seleccionar imágenes.',
          [{ text: 'OK' }]
        );
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1], // Mantener proporción cuadrada para mejor reconocimiento
        quality: 0.9, // Mayor calidad para mejor precisión
        base64: false,
      });

      if (!result.canceled && result.assets[0]) {
        setCapturedImage(result.assets[0].uri);
        setScanResult(null); // Limpiar resultado anterior
      }
    } catch (error) {
      Alert.alert(
        'Error',
        'No se pudo seleccionar la imagen. Intenta de nuevo.',
        [{ text: 'OK' }]
      );
    } finally {
      setIsLoading(false);
    }
  };

  const scanImage = async () => {
    if (!capturedImage) {
      Alert.alert('Error', 'Primero selecciona una foto de la nariz de la mascota');
      return;
    }

    setIsScanning(true);
    try {
      const formData = new FormData();
      const imageFile = {
        uri: capturedImage,
        type: 'image/jpeg',
        name: 'scan.jpg',
      } as any;
      formData.append('image', imageFile);

      const result = await apiService.scanPet(formData);
      setScanResult(result);
      
      // No mostrar Alert automático, dejar que el usuario vea el resultado y decida
      // El resultado se mostrará en la UI y tendrá opciones para crear alerta
    } catch (error: any) {
      console.error('Error en escaneo:', error);
      Alert.alert(
        'Error de Escaneo',
        error.response?.data?.message || 'Error al procesar la imagen. Verifica tu conexión e intenta de nuevo.',
        [{ text: 'OK' }]
      );
    } finally {
      setIsScanning(false);
    }
  };

  const performVisualComparison = async () => {
    if (!capturedImage) {
      Alert.alert('Error', 'Primero selecciona una foto de la nariz de la mascota');
      return;
    }

    setIsComparing(true);
    try {
      const formData = new FormData();
      const imageFile = {
        uri: capturedImage,
        type: 'image/jpeg',
        name: 'comparison.jpg',
      } as any;
      formData.append('image', imageFile);

      const result = await apiService.visualComparison(formData);
      setVisualComparison(result);
      console.log('✅ Comparación visual completada:', result);
      console.log('📊 Top matches:', result.top_matches?.length || 0);
      console.log('📊 Registered pets:', result.registered_pets_comparison?.length || 0);
      console.log('🖼️ Primera mascota con imagen:', result.registered_pets_comparison?.[0]?.noseImageUrl);
      
      // Limpiar formulario después del análisis
      clearFormAfterAnalysis();
    } catch (error: any) {
      console.error('Error en comparación visual:', error);
      Alert.alert(
        'Error de Comparación',
        error.response?.data?.message || 'Error al realizar la comparación visual. Verifica tu conexión e intenta de nuevo.',
        [{ text: 'OK' }]
      );
    } finally {
      setIsComparing(false);
    }
  };

  const resetScan = () => {
    setCapturedImage(null);
    setScanResult(null);
    setVisualComparison(null);
    setIsComparing(false);
  };

  const [autoClearCountdown, setAutoClearCountdown] = useState<number | null>(null);
  const [clearTimeoutId, setClearTimeoutId] = useState<number | null>(null);
  const [countdownIntervalId, setCountdownIntervalId] = useState<number | null>(null);

  const clearFormAfterAnalysis = () => {
    // Mostrar countdown de 10 segundos
    setAutoClearCountdown(10);
    
    const interval = setInterval(() => {
      setAutoClearCountdown(prev => {
        if (prev && prev > 1) {
          return prev - 1;
        } else {
          clearInterval(interval);
          return null;
        }
      });
    }, 1000);
    
    setCountdownIntervalId(interval);

    // Limpiar formulario después del análisis para nuevas comparaciones
    const timeout = setTimeout(() => {
      setCapturedImage(null);
      setScanResult(null);
      setVisualComparison(null);
      setIsComparing(false);
      setAutoClearCountdown(null);
      setClearTimeoutId(null);
      setCountdownIntervalId(null);
    }, 10000); // Limpiar después de 10 segundos para que el usuario vea los resultados
    
    setClearTimeoutId(timeout);
  };

  const cancelAutoClear = () => {
    if (clearTimeoutId) {
      clearTimeout(clearTimeoutId);
      setClearTimeoutId(null);
    }
    if (countdownIntervalId) {
      clearInterval(countdownIntervalId);
      setCountdownIntervalId(null);
    }
    setAutoClearCountdown(null);
  };



  const takePhoto = async () => {
    try {
      setIsLoading(true);
      
      // Solicitar permisos de cámara
      const { status } = await ImagePicker.requestCameraPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert(
          'Permisos Requeridos',
          'Necesitamos acceso a tu cámara para tomar fotos.',
          [{ text: 'OK' }]
        );
        return;
      }

      const result = await ImagePicker.launchCameraAsync({
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.9,
        base64: false,
      });

      if (!result.canceled && result.assets[0]) {
        setCapturedImage(result.assets[0].uri);
        setScanResult(null);
      }
    } catch (error) {
      Alert.alert(
        'Error',
        'No se pudo tomar la foto. Intenta de nuevo.',
        [{ text: 'OK' }]
      );
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: colors.background }]}>
      <CustomHeader />

      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={[styles.header, { backgroundColor: colors.card, borderBottomColor: colors.border }]}>
          <Text style={[styles.title, { color: colors.text }]}>Escanear Mascota</Text>
          <Text style={[styles.subtitle, { color: colors.placeholder }]}>
            Identifica mascotas por su huella nasal única
          </Text>
        </View>

        {!capturedImage ? (
          <View style={styles.uploadContainer}>
            <View style={[styles.uploadArea, { backgroundColor: colors.card }]}>
              <Text style={styles.uploadIcon}>🐕</Text>
              <Text style={[styles.uploadText, { color: colors.text }]}>
                Selecciona una foto clara de la nariz de la mascota
              </Text>
              <Text style={[styles.uploadHint, { color: colors.placeholder }]}>
                Asegúrate de que la nariz esté bien iluminada y enfocada
              </Text>
              
              <View style={styles.buttonContainer}>
                <TouchableOpacity 
                  style={[styles.primaryButton, { backgroundColor: colors.primary }]} 
                  onPress={takePhoto}
                  disabled={isLoading}
                >
                  {isLoading ? (
                    <ActivityIndicator color="white" size="small" />
                  ) : (
                    <>
                      <Text style={styles.buttonIcon}>📷</Text>
                      <Text style={styles.primaryButtonText}>Tomar Foto</Text>
                    </>
                  )}
                </TouchableOpacity>
                
                <TouchableOpacity 
                  style={[styles.secondaryButton, { borderColor: colors.primary }]} 
                  onPress={pickImage}
                  disabled={isLoading}
                >
                  <Text style={styles.buttonIcon}>🖼️</Text>
                  <Text style={[styles.secondaryButtonText, { color: colors.primary }]}>
                    Seleccionar de Galería
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        ) : (
          <View style={styles.resultContainer}>
            <View style={styles.imageContainer}>
              <Image source={{ uri: capturedImage }} style={styles.capturedImage} />
              <View style={styles.imageOverlay}>
                <Text style={styles.imageOverlayText}>Imagen seleccionada</Text>
              </View>
            </View>
            
            {!scanResult ? (
              <View style={styles.scanActions}>
                <TouchableOpacity
                  style={[
                    styles.scanButton, 
                    { backgroundColor: colors.primary }, 
                    isComparing && styles.buttonDisabled
                  ]}
                  onPress={performVisualComparison}
                  disabled={isComparing}
                >
                  {isComparing ? (
                    <View style={styles.loadingContainer}>
                      <ActivityIndicator color="white" size="small" />
                      <Text style={styles.scanButtonText}>Analizando patrones...</Text>
                    </View>
                  ) : (
                    <>
                      <Text style={styles.scanIcon}>🔬</Text>
                      <Text style={styles.scanButtonText}>Analizar</Text>
                    </>
                  )}
                </TouchableOpacity>
                
                <TouchableOpacity 
                  style={[styles.resetButton, { borderColor: colors.border }]} 
                  onPress={resetScan}
                >
                  <Text style={[styles.resetButtonText, { color: colors.text }]}>
                    Seleccionar Otra Foto
                  </Text>
                </TouchableOpacity>
              </View>
            ) : (
              <View style={styles.resultDisplay}>
                <View style={[styles.resultCard, { backgroundColor: colors.card }]}>
                  <Text style={[styles.resultIcon, { color: scanResult.match ? '#27ae60' : '#e74c3c' }]}>
                    {scanResult.match ? '✅' : '❌'}
                  </Text>
                  <Text style={[styles.resultTitle, { color: colors.text }]}>
                    {scanResult.match ? '¡Mascota Encontrada!' : 'No se encontró coincidencia'}
                  </Text>
                  
                  {scanResult.match && (
                    <View style={styles.matchInfo}>
                      <Text style={[styles.petNameText, { color: colors.text }]}>
                        🐕 {scanResult.petName || 'Mascota Encontrada'}
                      </Text>
                      <View style={styles.confidenceBar}>
                        <View 
                          style={[
                            styles.confidenceFill, 
                            { 
                              width: `${Math.min(scanResult.confidence * 100, 100)}%`,
                              backgroundColor: scanResult.confidence > 0.8 ? '#27ae60' : '#f39c12'
                            }
                          ]} 
                        />
                      </View>
                      <Text style={[styles.confidenceText, { color: colors.text }]}>
                        Confianza: {(scanResult.confidence * 100).toFixed(1)}%
                      </Text>
                      <Text style={[styles.petIdText, { color: colors.placeholder }]}>
                        ID: {scanResult.petId}
                      </Text>
                    </View>
                  )}
                  
                  {!scanResult.match && (
                    <Text style={[styles.noMatchText, { color: colors.placeholder }]}>
                      Intenta con una foto más clara de la nariz, con mejor iluminación
                    </Text>
                  )}
                </View>
                
                {scanResult.match ? (
                  <View style={styles.actionButtons}>
                    <TouchableOpacity 
                      style={[styles.primaryActionButton, { backgroundColor: colors.primary }]} 
                      onPress={() => router.push('/(tabs)/alert-create')}
                    >
                      <Text style={styles.primaryActionButtonText}>🚨 Crear Alerta</Text>
                    </TouchableOpacity>
                    <TouchableOpacity 
                      style={[styles.secondaryActionButton, { borderColor: colors.primary }]} 
                      onPress={resetScan}
                    >
                      <Text style={[styles.secondaryActionButtonText, { color: colors.primary }]}>
                        🔍 Escanear Otra Mascota
                      </Text>
                    </TouchableOpacity>
                  </View>
                ) : (
                  <TouchableOpacity 
                    style={[styles.scanButton, { backgroundColor: colors.primary }]} 
                    onPress={resetScan}
                  >
                    <Text style={styles.scanButtonText}>🔄 Volver a Intentar</Text>
                  </TouchableOpacity>
                )}
              </View>
            )}

            {/* Comparación Visual */}
            {visualComparison && (
              <View style={styles.visualComparisonContainer}>
                <Text style={[styles.visualComparisonTitle, { color: colors.text }]}>
                  🔬 Análisis Detallado de Patrones
                </Text>
                
                {/* Imagen escaneada vs imágenes registradas */}
                <View style={styles.imageComparisonContainer}>
                  <Text style={[styles.imageComparisonTitle, { color: colors.text }]}>
                    📸 Comparación Visual de Imágenes
                  </Text>
                  
                  {/* Imagen escaneada */}
                  <View style={styles.scannedImageContainer}>
                    <Text style={[styles.imageLabel, { color: colors.text }]}>
                      🎯 Imagen Escaneada
                    </Text>
                    <Image source={{ uri: capturedImage }} style={styles.comparisonImage} />
                  </View>
                  
                  {/* Top 3 imágenes registradas */}
                  {visualComparison.registered_pets_comparison && visualComparison.registered_pets_comparison.length > 0 && (
                    <View style={styles.registeredImagesContainer}>
                      <Text style={[styles.registeredImagesTitle, { color: colors.text }]}>
                        🐕 Mascotas Registradas (Top 3)
                      </Text>
                      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.imagesScroll}>
                        {visualComparison.registered_pets_comparison.slice(0, 3).map((match: any, index: number) => (
                          <View key={match.petId} style={styles.registeredImageCard}>
                            <Image 
                              source={{ uri: match.noseImageUrl || 'https://via.placeholder.com/150x150?text=Nariz' }} 
                              style={styles.registeredImage}
                              defaultSource={{ uri: 'https://via.placeholder.com/150x150?text=Nariz' }}
                            />
                            <View style={styles.imageInfo}>
                              <Text style={[styles.imagePetName, { color: colors.text }]}>
                                {match.petName}
                              </Text>
                              <Text style={[styles.imageScore, { color: colors.primary }]}>
                                {(match.final_score * 100).toFixed(1)}%
                              </Text>
                              <View style={styles.patternIndicator}>
                                <Text style={[styles.patternText, { color: colors.placeholder }]}>
                                  {match.final_score > 0.8 ? '🔴 Patrones Similares' : 
                                   match.final_score > 0.6 ? '🟡 Patrones Parciales' : '⚫ Patrones Diferentes'}
                                </Text>
                              </View>
                            </View>
                          </View>
                        ))}
                      </ScrollView>
                    </View>
                  )}
                </View>
                
                {/* Resumen del análisis */}
                <View style={[styles.analysisSummary, { backgroundColor: colors.card }]}>
                  <Text style={[styles.analysisTitle, { color: colors.text }]}>
                    Resumen del Análisis
                  </Text>
                  <Text style={[styles.analysisText, { color: colors.text }]}>
                    📊 Mascotas comparadas: {visualComparison.analysis_summary?.total_pets_compared || 0}
                  </Text>
                  <Text style={[styles.analysisText, { color: colors.text }]}>
                    ✅ Coincidencias encontradas: {visualComparison.analysis_summary?.matching_pets || 0}
                  </Text>
                  <Text style={[styles.analysisText, { color: colors.text }]}>
                    🎯 Mejor puntuación: {(visualComparison.analysis_summary?.best_match_score * 100 || 0).toFixed(1)}%
                  </Text>
                  <Text style={[styles.analysisText, { color: colors.text }]}>
                    📏 Umbral usado: {(visualComparison.analysis_summary?.threshold_used * 100 || 0).toFixed(1)}%
                  </Text>
                </View>

                {/* Top matches */}
                {visualComparison.top_matches && visualComparison.top_matches.length > 0 && (
                  <View style={styles.topMatchesContainer}>
                    <Text style={[styles.topMatchesTitle, { color: colors.text }]}>
                      🏆 Mejores Coincidencias
                    </Text>
                    {visualComparison.top_matches.slice(0, 3).map((match: any, index: number) => (
                      <View key={match.petId} style={[styles.matchCard, { backgroundColor: colors.card }]}>
                        <View style={styles.matchHeader}>
                          <Text style={[styles.matchRank, { color: colors.primary }]}>
                            #{index + 1}
                          </Text>
                          <Text style={[styles.matchName, { color: colors.text }]}>
                            🐕 {match.petName}
                          </Text>
                          <Text style={[styles.matchBreed, { color: colors.placeholder }]}>
                            {match.breed}
                          </Text>
                        </View>
                        
                        <View style={styles.matchScores}>
                          <View style={styles.scoreBar}>
                            <Text style={[styles.scoreLabel, { color: colors.text }]}>
                              Puntuación Final:
                            </Text>
                            <View style={styles.confidenceBar}>
                              <View 
                                style={[
                                  styles.confidenceFill, 
                                  { 
                                    width: `${Math.min(match.final_score * 100, 100)}%`,
                                    backgroundColor: match.final_score > 0.8 ? '#27ae60' : 
                                                   match.final_score > 0.6 ? '#f39c12' : '#e74c3c'
                                  }
                                ]} 
                              />
                            </View>
                            <Text style={[styles.scoreValue, { color: colors.text }]}>
                              {(match.final_score * 100).toFixed(1)}%
                            </Text>
                          </View>
                          
                          {/* Scores por modelo */}
                          <View style={styles.modelScores}>
                            <Text style={[styles.modelScoresTitle, { color: colors.text }]}>
                              Puntuaciones por Modelo:
                            </Text>
                            {Object.entries(match.model_scores || {}).map(([model, score]: [string, any]) => (
                              <View key={model} style={styles.modelScore}>
                                <Text style={[styles.modelName, { color: colors.placeholder }]}>
                                  {model === 'mobilenet' ? '📱 MobileNet' :
                                   model === 'efficientnet' ? '⚡ EfficientNet' :
                                   model === 'nose_specific' ? '👃 Específico Nariz' : model}:
                                </Text>
                                <Text style={[styles.modelScoreValue, { color: colors.text }]}>
                                  {(score * 100).toFixed(1)}%
                                </Text>
                              </View>
                            ))}
                          </View>
                        </View>
                      </View>
                    ))}
                  </View>
                )}

                {/* Botón para nueva comparación */}
                <View style={styles.newComparisonContainer}>
                  {autoClearCountdown && (
                    <View style={styles.countdownContainer}>
                      <Text style={[styles.countdownText, { color: colors.placeholder }]}>
                        ⏰ Formulario se limpiará en {autoClearCountdown} segundos
                      </Text>
                      <TouchableOpacity 
                        style={styles.cancelAutoClearButton}
                        onPress={cancelAutoClear}
                      >
                        <Text style={styles.cancelAutoClearText}>
                          ❌ Cancelar limpieza automática
                        </Text>
                      </TouchableOpacity>
                    </View>
                  )}
                  <TouchableOpacity 
                    style={[styles.newComparisonButton, { backgroundColor: colors.primary }]} 
                    onPress={resetScan}
                  >
                    <Text style={styles.newComparisonButtonText}>
                      🔍 Nueva Comparación
                    </Text>
                  </TouchableOpacity>
                </View>

              </View>
            )}
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContainer: {
    flexGrow: 1,
  },
  header: {
    alignItems: 'center',
    padding: 20,
    paddingTop: 50, // Aumentado para evitar la barra de estado
    paddingBottom: 20,
    borderBottomWidth: 1,
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
  uploadContainer: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
    paddingTop: 40, // Reducido porque el header ya tiene más espacio
  },
  uploadArea: {
    borderRadius: 16,
    padding: 30,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.1,
    shadowRadius: 12,
    elevation: 8,
  },
  uploadIcon: {
    fontSize: 72,
    marginBottom: 20,
  },
  uploadText: {
    fontSize: 18,
    textAlign: 'center',
    marginBottom: 10,
    lineHeight: 24,
    fontWeight: '600',
  },
  uploadHint: {
    fontSize: 14,
    textAlign: 'center',
    marginBottom: 30,
    lineHeight: 20,
    fontStyle: 'italic',
  },
  buttonContainer: {
    width: '100%',
    gap: 15,
  },
  primaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 30,
    paddingVertical: 16,
    borderRadius: 12,
    gap: 10,
  },
  primaryButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  secondaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderRadius: 12,
    paddingHorizontal: 30,
    paddingVertical: 16,
    gap: 10,
  },
  secondaryButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  buttonIcon: {
    fontSize: 20,
  },
  resultContainer: {
    flex: 1,
    padding: 20,
  },
  imageContainer: {
    position: 'relative',
    marginBottom: 20,
  },
  capturedImage: {
    width: '100%',
    height: 300,
    borderRadius: 16,
  },
  imageOverlay: {
    position: 'absolute',
    top: 10,
    right: 10,
    backgroundColor: 'rgba(0,0,0,0.7)',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  imageOverlayText: {
    color: 'white',
    fontSize: 12,
    fontWeight: '600',
  },
  scanActions: {
    flex: 1,
    justifyContent: 'center',
    gap: 15,
  },
  scanButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    padding: 18,
    gap: 10,
  },
  buttonDisabled: {
    backgroundColor: '#bdc3c7',
  },
  scanButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  scanIcon: {
    fontSize: 20,
  },
  loadingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  resetButton: {
    borderWidth: 1,
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
  },
  resetButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  resultDisplay: {
    flex: 1,
    justifyContent: 'center',
    gap: 20,
  },
  resultCard: {
    borderRadius: 16,
    padding: 24,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 5,
  },
  resultIcon: {
    fontSize: 48,
    marginBottom: 16,
  },
  resultTitle: {
    fontSize: 22,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
  },
  matchInfo: {
    width: '100%',
    alignItems: 'center',
  },
  petNameText: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  confidenceBar: {
    flex: 1,
    height: 8,
    backgroundColor: '#ecf0f1',
    borderRadius: 4,
    marginHorizontal: 8,
    overflow: 'hidden',
  },
  confidenceFill: {
    height: '100%',
    borderRadius: 4,
  },
  confidenceText: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
  petIdText: {
    fontSize: 14,
    fontFamily: 'monospace',
  },
  noMatchText: {
    fontSize: 16,
    textAlign: 'center',
    lineHeight: 22,
  },
  actionButtons: {
    width: '100%',
    gap: 15,
  },
  primaryActionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    padding: 18,
    gap: 10,
  },
  primaryActionButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  secondaryActionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderRadius: 12,
    padding: 18,
    gap: 10,
  },
  secondaryActionButtonText: {
    fontSize: 16,
    fontWeight: '600',
  },
  // Estilos para comparación visual
  visualComparisonContainer: {
    marginTop: 20,
    padding: 20,
  },
  visualComparisonTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
  },
  analysisSummary: {
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  analysisTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  analysisText: {
    fontSize: 14,
    marginBottom: 6,
  },
  topMatchesContainer: {
    marginBottom: 20,
  },
  topMatchesTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  matchCard: {
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  matchHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
    gap: 8,
  },
  matchRank: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  matchName: {
    fontSize: 16,
    fontWeight: '600',
    flex: 1,
  },
  matchBreed: {
    fontSize: 14,
  },
  matchScores: {
    gap: 12,
  },
  scoreBar: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  scoreLabel: {
    fontSize: 14,
    fontWeight: '600',
    minWidth: 120,
  },
  scoreValue: {
    fontSize: 14,
    fontWeight: 'bold',
    minWidth: 50,
    textAlign: 'right',
  },
  modelScores: {
    gap: 6,
  },
  modelScoresTitle: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
  },
  modelScore: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  modelName: {
    fontSize: 12,
  },
  modelScoreValue: {
    fontSize: 12,
    fontWeight: '600',
  },

  // Estilos para comparación visual de imágenes
  imageComparisonContainer: {
    marginBottom: 20,
  },
  imageComparisonTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  scannedImageContainer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  imageLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  comparisonImage: {
    width: 200,
    height: 200,
    borderRadius: 12,
    borderWidth: 3,
    borderColor: '#3498db',
  },
  registeredImagesContainer: {
    marginBottom: 20,
  },
  registeredImagesTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 12,
    textAlign: 'center',
  },
  imagesScroll: {
    flexDirection: 'row',
  },
  registeredImageCard: {
    marginRight: 15,
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
    borderRadius: 12,
    padding: 12,
    minWidth: 150,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  registeredImage: {
    width: 120,
    height: 120,
    borderRadius: 8,
    marginBottom: 8,
  },
  imageInfo: {
    alignItems: 'center',
  },
  imagePetName: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
    textAlign: 'center',
  },
  imageScore: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 4,
  },
  patternIndicator: {
    alignItems: 'center',
  },
  patternText: {
    fontSize: 12,
    textAlign: 'center',
  },
  newComparisonContainer: {
    marginTop: 20,
    paddingHorizontal: 20,
  },
  newComparisonButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    padding: 18,
    gap: 10,
  },
  newComparisonButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  countdownContainer: {
    alignItems: 'center',
    marginBottom: 15,
    padding: 10,
    borderRadius: 8,
    backgroundColor: 'rgba(255, 193, 7, 0.1)',
  },
  countdownText: {
    fontSize: 14,
    fontWeight: '500',
    textAlign: 'center',
  },
  cancelAutoClearButton: {
    marginTop: 8,
    padding: 8,
    borderRadius: 6,
    backgroundColor: 'rgba(231, 76, 60, 0.1)',
  },
  cancelAutoClearText: {
    fontSize: 12,
    fontWeight: '500',
    color: '#e74c3c',
    textAlign: 'center',
  },
}); 