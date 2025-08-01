import os
from typing import List

class Config:
    # Configuración de la aplicación
    APP_NAME = "AI Service - PETNOW-DOGS"
    APP_VERSION = "2.0.0"
    
    # Configuración del servidor
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", 8000))
    
    # Configuración de CORS
    CORS_ORIGINS: List[str] = [
        "https://*.onrender.com",
        "https://*.vercel.app", 
        "http://localhost:19000",
        "http://localhost:3000"
    ]
    
    # Configuración de logging
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
    
    # Configuración de modelos
    SIMILARITY_THRESHOLD = float(os.getenv("SIMILARITY_THRESHOLD", "0.80"))
    CONFIDENCE_BOOST = float(os.getenv("CONFIDENCE_BOOST", "0.1"))
    
    # Configuración de archivos
    EMBEDDINGS_FILE = os.getenv("EMBEDDINGS_FILE", "nose_print_embeddings.json")
    AUDIT_LOG_FILE = os.getenv("AUDIT_LOG_FILE", "requests.log")
    
    # Configuración de base de datos (si se necesita en el futuro)
    DATABASE_URL = os.getenv("DATABASE_URL")
    
    # Configuración de Google Cloud Storage
    GCS_BUCKET_NAME = os.getenv("GCS_BUCKET_NAME")
    GOOGLE_CLOUD_PROJECT = os.getenv("GOOGLE_CLOUD_PROJECT")
    
    @classmethod
    def get_cors_origins(cls) -> List[str]:
        """Obtener orígenes CORS permitidos"""
        origins = cls.CORS_ORIGINS.copy()
        
        # Agregar orígenes desde variables de entorno
        env_origins = os.getenv("CORS_ORIGINS")
        if env_origins:
            origins.extend(env_origins.split(","))
            
        return origins 