import numpy as np
import cv2
import os
import json
from typing import List, Dict
import logging
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from tensorflow.keras.preprocessing import image
from tensorflow.keras.models import Model
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SimpleNoseModel:
    def __init__(self, embeddings_path: str = "embeddings.json"):
        self.embeddings_path = embeddings_path
        self.embeddings = {}
        # Umbral más estricto para evitar falsos positivos
        self.threshold = 0.85
        self.feature_extractor = None
        self._initialize_model()
        
    def _initialize_model(self):
        """Inicializar el modelo de extracción de características"""
        try:
            # Cargar MobileNetV2 pre-entrenado sin la capa de clasificación
            base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
            
            # Agregar capa de pooling global para obtener características
            x = base_model.output
            x = GlobalAveragePooling2D()(x)
            x = Dense(512, activation='relu')(x)
            x = Dropout(0.5)(x)
            x = Dense(256, activation='relu')(x)
            x = Dropout(0.3)(x)
            x = Dense(128, activation='relu')(x)
            
            # Crear modelo de extracción de características
            self.feature_extractor = Model(inputs=base_model.input, outputs=x)
            
            # Congelar las capas del modelo base
            for layer in base_model.layers:
                layer.trainable = False
                
            logger.info("Modelo de extracción de características inicializado correctamente")
            
        except Exception as e:
            logger.error(f"Error inicializando modelo: {e}")
            # Fallback a características tradicionales si falla el modelo de deep learning
            self.feature_extractor = None
        
    def preprocess_image(self, img_bytes: bytes) -> np.ndarray:
        """Preprocesamiento mejorado de imagen para deep learning"""
        # Convertir bytes a imagen
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
            
        # Convertir BGR a RGB
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        
        # Redimensionar a 224x224 (tamaño requerido por MobileNetV2)
        img = cv2.resize(img, (224, 224))
        
        # Convertir a formato de imagen de Keras
        img_array = image.img_to_array(img)
        
        # Expandir dimensiones para batch
        img_array = np.expand_dims(img_array, axis=0)
        
        # Preprocesamiento específico de MobileNetV2
        img_array = preprocess_input(img_array)
        
        return img_array
    
    def extract_features(self, img_bytes: bytes) -> List[float]:
        """Extraer características usando deep learning"""
        try:
            if self.feature_extractor is None:
                logger.warning("Modelo de deep learning no disponible, usando características tradicionales")
                return self._extract_traditional_features(img_bytes)
            
            # Preprocesar imagen
            img_array = self.preprocess_image(img_bytes)
            
            # Extraer características usando el modelo
            features = self.feature_extractor.predict(img_array, verbose=0)
            
            # Convertir a lista y normalizar
            features_list = features[0].tolist()
            
            # Normalización L2 para mejorar la comparación
            features_norm = np.array(features_list)
            features_norm = features_norm / np.linalg.norm(features_norm)
            
            logger.info(f"Características extraídas: {len(features_norm)} dimensiones")
            return features_norm.tolist()
            
        except Exception as e:
            logger.error(f"Error en extracción de características con deep learning: {e}")
            logger.info("Fallback a características tradicionales")
            return self._extract_traditional_features(img_bytes)
    
    def _extract_traditional_features(self, img_bytes: bytes) -> List[float]:
        """Extraer características tradicionales como fallback"""
        # Convertir bytes a imagen
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
            
        # Convertir a RGB
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        
        # Redimensionar
        img = cv2.resize(img, (224, 224))
        
        # Normalización
        img = img.astype(np.float32) / 255.0
        
        # Convertir a escala de grises
        gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        gray_uint8 = np.clip(gray.astype(np.float32) * 255, 0, 255).astype(np.uint8)
        
        features = []
        
        # Histograma
        hist = cv2.calcHist([gray_uint8], [0], None, [256], [0, 256])
        hist = hist.flatten() / hist.sum()
        features.extend(hist.tolist())
        
        # Características de textura
        grad_x = cv2.Sobel(gray_uint8, cv2.CV_64F, 1, 0, ksize=3)
        grad_y = cv2.Sobel(gray_uint8, cv2.CV_64F, 0, 1, ksize=3)
        magnitude = np.sqrt(grad_x.astype(np.float64)**2 + grad_y.astype(np.float64)**2)
        
        features.extend([
            float(np.mean(magnitude)),
            float(np.std(magnitude)),
            float(np.max(magnitude)),
            float(np.min(magnitude))
        ])
        
        # Características de color
        for channel in range(3):
            channel_img = img[:,:,channel]
            features.extend([
                float(np.mean(channel_img)),
                float(np.std(channel_img)),
                float(np.max(channel_img)),
                float(np.min(channel_img))
            ])
        
        # Momentos
        moments = cv2.moments(gray_uint8)
        features.extend([
            float(moments['m00']),
            float(moments['m10']),
            float(moments['m01']),
            float(moments['m20']),
            float(moments['m11']),
            float(moments['m02'])
        ])
        
        # Normalización L2
        features_norm = np.array(features)
        features_norm = features_norm / np.linalg.norm(features_norm)
        
        return features_norm.tolist()
    
    def load_embeddings(self):
        """Cargar embeddings guardados"""
        if os.path.exists(self.embeddings_path):
            with open(self.embeddings_path, 'r') as f:
                self.embeddings = json.load(f)
                logger.info(f"Cargados {len(self.embeddings)} embeddings")
        else:
            self.embeddings = {}
            logger.info("No se encontraron embeddings previos")
    
    def save_embeddings(self):
        """Guardar embeddings"""
        with open(self.embeddings_path, 'w') as f:
            json.dump(self.embeddings, f)
        logger.info(f"Guardados {len(self.embeddings)} embeddings")
    
    def register_pet(self, pet_id: str, img_bytes: bytes) -> Dict:
        """Registrar una nueva mascota con sus características"""
        try:
            features = self.extract_features(img_bytes)
            # Convertir numpy arrays a listas para serialización JSON
            features_list = [float(f) for f in features]
            self.embeddings[pet_id] = features_list
            self.save_embeddings()
            logger.info(f"Mascota {pet_id} registrada exitosamente")
            logger.info(f"Tamaño de características: {len(features_list)}")
            return {"status": "success", "pet_id": pet_id, "features_size": len(features_list)}
        except Exception as e:
            logger.error(f"Error registrando mascota {pet_id}: {str(e)}")
            return {"status": "error", "message": str(e)}
    
    def compare_nose(self, img_bytes: bytes) -> Dict:
        """Comparar nariz con embeddings registrados"""
        try:
            query_features = self.extract_features(img_bytes)
            
            if not self.embeddings:
                return {"match": False, "confidence": 0.0, "message": "No hay mascotas registradas"}
            
            # Calcular similitud con todas las mascotas registradas
            similarities = {}
            for pet_id, stored_features in self.embeddings.items():
                similarity = self.cosine_similarity(query_features, stored_features)
                similarities[pet_id] = similarity
                logger.info(f"Similitud con mascota {pet_id}: {similarity:.3f}")
            
            # Encontrar la mejor coincidencia
            best_pet = max(similarities.items(), key=lambda x: x[1])
            best_pet_id, best_score = best_pet
            
            logger.info(f"Mejor similitud: {best_score:.3f} con mascota {best_pet_id}")
            logger.info(f"Umbral actual: {self.threshold}")
            
            # Aplicar umbral más estricto
            if best_score >= self.threshold:
                return {
                    "match": True,
                    "pet_id": best_pet_id,
                    "confidence": round(float(best_score), 3),
                    "all_similarities": similarities
                }
            else:
                return {
                    "match": False,
                    "confidence": round(float(best_score), 3),
                    "best_candidate": best_pet_id,
                    "all_similarities": similarities,
                    "message": f"No se encontró coincidencia. Mejor similitud: {round(float(best_score), 3)} (umbral: {self.threshold})"
                }
                
        except Exception as e:
            logger.error(f"Error comparando nariz: {str(e)}")
            return {"match": False, "confidence": 0.0, "error": str(e)}
    
    def cosine_similarity(self, a: List[float], b: List[float]) -> float:
        """Calcular similitud coseno entre dos vectores de características"""
        a = np.array(a)
        b = np.array(b)
        return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
    
    def get_model_stats(self) -> Dict:
        """Obtener estadísticas del modelo"""
        return {
            "total_pets": len(self.embeddings),
            "embeddings_path": self.embeddings_path,
            "threshold": self.threshold,
            "model_type": "DeepLearningNoseModel",
            "feature_extractor_available": self.feature_extractor is not None
        } 