export default {
  expo: {
    name: "X-NOSE",
    slug: "xnose-app",
    version: "1.0.0",
    orientation: "portrait",
    icon: "./assets/images/xnose-logo.png",
    scheme: "myapp",
    userInterfaceStyle: "automatic",
    splash: {
      image: "./assets/images/xnose-logo.png",
      resizeMode: "contain",
      backgroundColor: "#20B2AA"
    },
    assetBundlePatterns: [
      "**/*"
    ],
    ios: {
      supportsTablet: true
    },
    android: {
      adaptiveIcon: {
        foregroundImage: "./assets/images/xnose-logo.png",
        backgroundColor: "#20B2AA"
      }
    },
    web: {
      bundler: "metro",
      output: "static",
      favicon: "./assets/images/xnose-logo.png"
    },
    plugins: [
      "expo-router"
    ],
    experiments: {
      typedRoutes: true
    },
    extra: {
      // Variables de entorno para producción
      apiUrl: process.env.EXPO_PUBLIC_API_URL || "https://petnow-gateway.onrender.com",
      gcsBucketUrl: process.env.EXPO_PUBLIC_GCS_BUCKET_URL || "https://storage.googleapis.com/petnow-dogs-images-app-biometrico-db",
      aiServiceUrl: process.env.EXPO_PUBLIC_AI_SERVICE_URL || "https://petnow-ai-service.onrender.com",
    }
  }
}; 