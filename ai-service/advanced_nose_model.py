import numpy as np
import cv2
import os
import json
from typing import List, Dict, Tuple
import logging
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2, EfficientNetB0
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input as mobilenet_preprocess
from tensorflow.keras.applications.efficientnet import preprocess_input as efficientnet_preprocess
from tensorflow.keras.preprocessing import image
from tensorflow.keras.models import Model
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense, Dropout, Concatenate
from sklearn.metrics.pairwise import cosine_similarity
import pickle
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AdvancedNoseModel:
    def __init__(self, embeddings_path: str = "advanced_embeddings.json"):
        self.embeddings_path = embeddings_path
        self.embeddings = {}
        self.feature_models = {}
        self.threshold = 0.75  # Umbral más flexible para mejor detección
        self.confidence_boost = 1.2  # Factor de boost para confianza
        self._initialize_models()
        
    def _initialize_models(self):
        """Inicializar múltiples modelos para extracción de características"""
        try:
            # Modelo 1: MobileNetV2 (rápido y eficiente)
            mobilenet_base = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
            mobilenet_x = mobilenet_base.output
            mobilenet_x = GlobalAveragePooling2D()(mobilenet_x)
            mobilenet_x = Dense(512, activation='relu')(mobilenet_x)
            mobilenet_x = Dropout(0.3)(mobilenet_x)
            mobilenet_x = Dense(256, activation='relu')(mobilenet_x)
            
            self.feature_models['mobilenet'] = Model(inputs=mobilenet_base.input, outputs=mobilenet_x)
            
            # Modelo 2: EfficientNetB0 (más preciso)
            efficientnet_base = EfficientNetB0(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
            efficientnet_x = efficientnet_base.output
            efficientnet_x = GlobalAveragePooling2D()(efficientnet_x)
            efficientnet_x = Dense(512, activation='relu')(efficientnet_x)
            efficientnet_x = Dropout(0.3)(efficientnet_x)
            efficientnet_x = Dense(256, activation='relu')(efficientnet_x)
            
            self.feature_models['efficientnet'] = Model(inputs=efficientnet_base.input, outputs=efficientnet_x)
            
            # Congelar capas base
            for model in self.feature_models.values():
                for layer in model.layers[:-6]:  # No congelar las últimas capas
                    layer.trainable = False
                    
            logger.info(f"Modelos inicializados: {list(self.feature_models.keys())}")
            
        except Exception as e:
            logger.error(f"Error inicializando modelos: {e}")
            self.feature_models = {}
    
    def preprocess_image_advanced(self, img_bytes: bytes) -> Dict[str, np.ndarray]:
        """Preprocesamiento avanzado para múltiples modelos"""
        # Convertir bytes a imagen
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
        
        # Convertir BGR a RGB
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        
        # Aplicar mejoras de imagen
        img_enhanced = self._enhance_image(img)
        
        processed_images = {}
        
        # Procesar para MobileNetV2
        mobilenet_img = cv2.resize(img_enhanced, (224, 224))
        mobilenet_array = image.img_to_array(mobilenet_img)
        mobilenet_array = np.expand_dims(mobilenet_array, axis=0)
        mobilenet_array = mobilenet_preprocess(mobilenet_array)
        processed_images['mobilenet'] = mobilenet_array
        
        # Procesar para EfficientNetB0
        efficientnet_img = cv2.resize(img_enhanced, (224, 224))
        efficientnet_array = image.img_to_array(efficientnet_img)
        efficientnet_array = np.expand_dims(efficientnet_array, axis=0)
        efficientnet_array = efficientnet_preprocess(efficientnet_array)
        processed_images['efficientnet'] = efficientnet_array
        
        return processed_images
    
    def _enhance_image(self, img: np.ndarray) -> np.ndarray:
        """Mejorar la calidad de la imagen para mejor detección"""
        # Convertir a float
        img_float = img.astype(np.float32) / 255.0
        
        # Aplicar CLAHE (Contrast Limited Adaptive Histogram Equalization)
        lab = cv2.cvtColor(img_float, cv2.COLOR_RGB2LAB)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
        lab[:,:,0] = clahe.apply(np.uint8(lab[:,:,0] * 255)) / 255.0
        enhanced = cv2.cvtColor(lab, cv2.COLOR_LAB2RGB)
        
        # Aplicar suavizado bilateral para reducir ruido
        enhanced = cv2.bilateralFilter(enhanced, 9, 75, 75)
        
        # Aplicar sharpening
        kernel = np.array([[-1,-1,-1], [-1,9,-1], [-1,-1,-1]])
        enhanced = cv2.filter2D(enhanced, -1, kernel)
        
        # Normalizar
        enhanced = np.clip(enhanced, 0, 1)
        
        return (enhanced * 255).astype(np.uint8)
    
    def extract_features_advanced(self, img_bytes: bytes) -> Dict[str, List[float]]:
        """Extraer características usando múltiples modelos"""
        try:
            if not self.feature_models:
                logger.warning("Modelos no disponibles, usando características tradicionales")
                return {'traditional': self._extract_traditional_features_advanced(img_bytes)}
            
            processed_images = self.preprocess_image_advanced(img_bytes)
            features = {}
            
            # Extraer características de cada modelo
            for model_name, model in self.feature_models.items():
                if model_name in processed_images:
                    img_array = processed_images[model_name]
                    model_features = model.predict(img_array, verbose=0)
                    
                    # Normalizar características
                    features_norm = model_features[0] / np.linalg.norm(model_features[0])
                    features[model_name] = features_norm.tolist()
            
            # Agregar características tradicionales como respaldo
            features['traditional'] = self._extract_traditional_features_advanced(img_bytes)
            
            logger.info(f"Características extraídas de {len(features)} modelos")
            return features
            
        except Exception as e:
            logger.error(f"Error en extracción avanzada: {e}")
            return {'traditional': self._extract_traditional_features_advanced(img_bytes)}
    
    def _extract_traditional_features_advanced(self, img_bytes: bytes) -> List[float]:
        """Extraer características tradicionales mejoradas"""
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
        
        # Convertir a RGB
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img = cv2.resize(img, (224, 224))
        
        features = []
        
        # Características de color mejoradas
        for channel in range(3):
            channel_img = img[:,:,channel]
            features.extend([
                float(np.mean(channel_img)),
                float(np.std(channel_img)),
                float(np.max(channel_img)),
                float(np.min(channel_img)),
                float(np.median(channel_img)),
                float(np.percentile(channel_img, 25)),
                float(np.percentile(channel_img, 75))
            ])
        
        # Convertir a escala de grises
        gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        
        # Histograma mejorado
        hist = cv2.calcHist([gray], [0], None, [256], [0, 256])
        hist = hist.flatten() / hist.sum()
        features.extend(hist.tolist())
        
        # Características de textura avanzadas
        # Gradientes
        grad_x = cv2.Sobel(gray, cv2.CV_64F, 1, 0, ksize=3)
        grad_y = cv2.Sobel(gray, cv2.CV_64F, 0, 1, ksize=3)
        magnitude = np.sqrt(grad_x**2 + grad_y**2)
        angle = np.arctan2(grad_y, grad_x)
        
        features.extend([
            float(np.mean(magnitude)),
            float(np.std(magnitude)),
            float(np.max(magnitude)),
            float(np.min(magnitude)),
            float(np.mean(angle)),
            float(np.std(angle))
        ])
        
        # Características de forma
        moments = cv2.moments(gray)
        features.extend([
            float(moments['m00']),
            float(moments['m10']),
            float(moments['m01']),
            float(moments['m20']),
            float(moments['m11']),
            float(moments['m02'])
        ])
        
        # Características de borde
        edges = cv2.Canny(gray, 50, 150)
        features.extend([
            float(np.sum(edges > 0)),
            float(np.mean(edges)),
            float(np.std(edges))
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
                logger.info(f"Cargados {len(self.embeddings)} embeddings avanzados")
        else:
            self.embeddings = {}
            logger.info("No se encontraron embeddings avanzados previos")
    
    def save_embeddings(self):
        """Guardar embeddings"""
        with open(self.embeddings_path, 'w') as f:
            json.dump(self.embeddings, f)
        logger.info(f"Guardados {len(self.embeddings)} embeddings avanzados")
    
    def register_pet_advanced(self, pet_id: str, img_bytes: bytes) -> Dict:
        """Registrar una nueva mascota con características avanzadas"""
        try:
            features = self.extract_features_advanced(img_bytes)
            
            # Convertir numpy arrays a listas para serialización JSON
            features_serializable = {}
            for model_name, model_features in features.items():
                features_serializable[model_name] = [float(f) for f in model_features]
            
            self.embeddings[pet_id] = features_serializable
            self.save_embeddings()
            
            total_features = sum(len(f) for f in features_serializable.values())
            logger.info(f"Mascota {pet_id} registrada con {len(features_serializable)} modelos")
            logger.info(f"Total de características: {total_features}")
            
            return {
                "status": "success", 
                "pet_id": pet_id, 
                "models_used": list(features_serializable.keys()),
                "total_features": total_features
            }
            
        except Exception as e:
            logger.error(f"Error registrando mascota {pet_id}: {str(e)}")
            return {"status": "error", "message": str(e)}
    
    def compare_nose_advanced(self, img_bytes: bytes) -> Dict:
        """Comparar nariz con embeddings registrados usando múltiples modelos"""
        try:
            query_features = self.extract_features_advanced(img_bytes)
            
            if not self.embeddings:
                return {
                    "match": False, 
                    "confidence": 0.0, 
                    "message": "No hay mascotas registradas"
                }
            
            # Calcular similitud con todas las mascotas registradas
            similarities = {}
            model_weights = {
                'mobilenet': 0.3,
                'efficientnet': 0.4,
                'traditional': 0.3
            }
            
            for pet_id, stored_features in self.embeddings.items():
                pet_similarities = {}
                weighted_score = 0.0
                total_weight = 0.0
                
                # Calcular similitud para cada modelo
                for model_name, model_features in query_features.items():
                    if model_name in stored_features:
                        similarity = self.cosine_similarity_advanced(
                            model_features, 
                            stored_features[model_name]
                        )
                        pet_similarities[model_name] = similarity
                        
                        # Aplicar peso del modelo
                        weight = model_weights.get(model_name, 0.1)
                        weighted_score += similarity * weight
                        total_weight += weight
                
                # Calcular score promedio ponderado
                if total_weight > 0:
                    final_score = weighted_score / total_weight
                else:
                    final_score = 0.0
                
                similarities[pet_id] = {
                    'final_score': final_score,
                    'model_scores': pet_similarities
                }
                
                logger.info(f"Similitud con {pet_id}: {final_score:.3f}")
                for model, score in pet_similarities.items():
                    logger.info(f"  {model}: {score:.3f}")
            
            # Encontrar la mejor coincidencia
            best_pet = max(similarities.items(), key=lambda x: x[1]['final_score'])
            best_pet_id, best_result = best_pet
            best_score = best_result['final_score']
            
            logger.info(f"Mejor similitud: {best_score:.3f} con mascota {best_pet_id}")
            logger.info(f"Umbral actual: {self.threshold}")
            
            # Aplicar umbral con boost de confianza
            adjusted_threshold = self.threshold / self.confidence_boost
            
            if best_score >= adjusted_threshold:
                # Calcular confianza final con boost
                confidence = min(1.0, best_score * self.confidence_boost)
                
                return {
                    "match": True,
                    "pet_id": best_pet_id,
                    "confidence": round(float(confidence), 3),
                    "raw_score": round(float(best_score), 3),
                    "all_similarities": similarities,
                    "message": f"Coincidencia encontrada con confianza {confidence:.1%}"
                }
            else:
                return {
                    "match": False,
                    "confidence": round(float(best_score), 3),
                    "best_candidate": best_pet_id,
                    "all_similarities": similarities,
                    "message": f"No se encontró coincidencia. Mejor similitud: {best_score:.3f} (umbral: {adjusted_threshold:.3f})"
                }
                
        except Exception as e:
            logger.error(f"Error comparando nariz: {str(e)}")
            return {"match": False, "confidence": 0.0, "error": str(e)}
    
    def cosine_similarity_advanced(self, a: List[float], b: List[float]) -> float:
        """Calcular similitud coseno mejorada"""
        a = np.array(a)
        b = np.array(b)
        
        # Verificar que los vectores no sean cero
        if np.linalg.norm(a) == 0 or np.linalg.norm(b) == 0:
            return 0.0
        
        return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
    
    def get_model_stats(self) -> Dict:
        """Obtener estadísticas del modelo avanzado"""
        return {
            "total_pets": len(self.embeddings),
            "embeddings_path": self.embeddings_path,
            "threshold": self.threshold,
            "confidence_boost": self.confidence_boost,
            "model_type": "AdvancedMultiModelNoseRecognition",
            "available_models": list(self.feature_models.keys()),
            "model_weights": {
                'mobilenet': 0.3,
                'efficientnet': 0.4,
                'traditional': 0.3
            }
        }
    
    def update_threshold(self, new_threshold: float):
        """Actualizar umbral de similitud"""
        if 0.0 <= new_threshold <= 1.0:
            self.threshold = new_threshold
            logger.info(f"Umbral actualizado a: {new_threshold}")
        else:
            raise ValueError("Threshold must be between 0.0 and 1.0")
    
    def update_confidence_boost(self, new_boost: float):
        """Actualizar factor de boost de confianza"""
        if new_boost > 0:
            self.confidence_boost = new_boost
            logger.info(f"Confidence boost actualizado a: {new_boost}")
        else:
            raise ValueError("Confidence boost must be positive") 