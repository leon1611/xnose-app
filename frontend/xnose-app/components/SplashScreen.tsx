import React from 'react';
import { View, Text, StyleSheet, Dimensions, Image } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';

const { width, height } = Dimensions.get('window');

export default function CustomSplashScreen() {
  return (
    <LinearGradient
      colors={['#20B2AA', '#48D1CC']}
      style={styles.container}
    >
      <View style={styles.content}>
        {/* Logo circular principal */}
        <View style={styles.logoContainer}>
          <Image 
            source={require('../assets/images/xnose-logo.png')}
            style={styles.logoImage}
            resizeMode="contain"
          />
        </View>
        
        {/* Nombre de la app con logo minimalista */}
        <View style={styles.nameContainer}>
          <Image 
            source={require('../assets/images/name.jpeg')}
            style={styles.nameImage}
            resizeMode="contain"
          />
        </View>
        
        <Text style={styles.appSubtitle}>Identificación Biométrica</Text>
        
        {/* Loading indicator */}
        <View style={styles.loadingContainer}>
          <View style={styles.loadingDot} />
          <View style={[styles.loadingDot, styles.loadingDot2]} />
          <View style={[styles.loadingDot, styles.loadingDot3]} />
        </View>
      </View>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    alignItems: 'center',
  },
  logoContainer: {
    width: 180,
    height: 180,
    borderRadius: 90,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 30,
    padding: 25,
  },
  logoImage: {
    width: 130,
    height: 130,
    borderRadius: 65,
  },
  nameContainer: {
    marginBottom: 20,
  },
  nameImage: {
    width: 200,
    height: 60,
    borderRadius: 8,
  },
  appSubtitle: {
    fontSize: 18,
    color: 'rgba(255, 255, 255, 0.9)',
    marginBottom: 60,
    fontWeight: '500',
  },
  loadingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  loadingDot: {
    width: 14,
    height: 14,
    borderRadius: 7,
    backgroundColor: 'white',
    marginHorizontal: 5,
    opacity: 0.6,
  },
  loadingDot2: {
    opacity: 0.8,
  },
  loadingDot3: {
    opacity: 1,
  },
}); 