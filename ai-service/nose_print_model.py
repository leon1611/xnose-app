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

class NosePrintModel:
    def __init__(self, embeddings_path="nose_print_embeddings.json"):
        self.embeddings_path = embeddings_path
        self.embeddings = {}
        self.feature_models = {}
        # Umbral más estricto para huellas nasales
        self.threshold = 0.85  # Reducido de 0.90 para ser más flexible
        self.confidence_boost = 1.2  # Aumentado para compensar la flexibilidad
        self._initialize_models()
        self.load_embeddings()
        
    def _initialize_models(self):
        """Inicializar modelos específicos para huellas nasales"""
        try:
            # Modelo 1: MobileNetV2 optimizado para texturas
            mobilenet_base = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
            mobilenet_x = mobilenet_base.output
            mobilenet_x = GlobalAveragePooling2D()(mobilenet_x)
            mobilenet_x = Dense(1024, activation='relu')(mobilenet_x)
            mobilenet_x = Dropout(0.4)(mobilenet_x)
            mobilenet_x = Dense(512, activation='relu')(mobilenet_x)
            mobilenet_x = Dropout(0.3)(mobilenet_x)
            mobilenet_x = Dense(256, activation='relu')(mobilenet_x)
            
            self.feature_models['mobilenet'] = Model(inputs=mobilenet_base.input, outputs=mobilenet_x)
            
            # Modelo 2: EfficientNetB0 para detalles finos
            efficientnet_base = EfficientNetB0(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
            efficientnet_x = efficientnet_base.output
            efficientnet_x = GlobalAveragePooling2D()(efficientnet_x)
            efficientnet_x = Dense(1024, activation='relu')(efficientnet_x)
            efficientnet_x = Dropout(0.4)(efficientnet_x)
            efficientnet_x = Dense(512, activation='relu')(efficientnet_x)
            efficientnet_x = Dropout(0.3)(efficientnet_x)
            efficientnet_x = Dense(256, activation='relu')(efficientnet_x)
            
            self.feature_models['efficientnet'] = Model(inputs=efficientnet_base.input, outputs=efficientnet_x)
            
            # Congelar capas base
            for model in self.feature_models.values():
                for layer in model.layers[:-9]:  # No congelar las últimas capas
                    layer.trainable = False
                    
            logger.info(f"Modelos de huella nasal inicializados: {list(self.feature_models.keys())}")
            
        except Exception as e:
            logger.error(f"Error inicializando modelos: {e}")
            self.feature_models = {}
    
    def preprocess_nose_image(self, img_bytes: bytes) -> Dict[str, np.ndarray]:
        """Preprocesamiento específico para imágenes de nariz"""
        # Convertir bytes a imagen
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_UNCHANGED)
        
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
        
        # Manejar imágenes con canal alfa (RGBA)
        if img.shape[-1] == 4:  # RGBA
            # Convertir RGBA a RGB usando fondo blanco
            alpha = img[:, :, 3] / 255.0
            rgb = img[:, :, :3].astype(np.float32)
            white_background = np.ones_like(rgb) * 255
            img = (rgb * alpha[:, :, np.newaxis] + white_background * (1 - alpha[:, :, np.newaxis])).astype(np.uint8)
        elif img.shape[-1] == 3:  # BGR
            # Convertir BGR a RGB
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        else:
            # Convertir escala de grises a RGB
            img = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)
        
        # Aplicar mejoras específicas para nariz
        img_enhanced = self._enhance_nose_image(img)
        
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
    
    def _enhance_nose_image(self, img: np.ndarray) -> np.ndarray:
        """MEJORADO: Convertir a blanco y negro y resaltar relieves, grietas y bordes de la nariz"""
        img_float = img.astype(np.float32) / 255.0
        
        # Convertir a escala de grises para procesamiento
        gray = cv2.cvtColor(img_float, cv2.COLOR_RGB2GRAY)
        gray_uint8 = np.uint8(gray * 255)
        
        # 1. CLAHE AGRESIVO para resaltar contrastes locales
        clahe = cv2.createCLAHE(clipLimit=6.0, tileGridSize=(8,8))
        gray_enhanced = clahe.apply(gray_uint8)
        
        # 2. DETECCIÓN DE BORDES MÚLTIPLE para capturar diferentes tipos de relieves
        # Bordes de Canny para grietas finas
        edges_canny = cv2.Canny(gray_enhanced, 20, 80)
        
        # Bordes de Sobel para relieves más suaves
        sobel_x = cv2.Sobel(gray_enhanced, cv2.CV_64F, 1, 0, ksize=3)
        sobel_y = cv2.Sobel(gray_enhanced, cv2.CV_64F, 0, 1, ksize=3)
        sobel_magnitude = np.sqrt(sobel_x**2 + sobel_y**2)
        sobel_normalized = np.uint8(sobel_magnitude * 255 / sobel_magnitude.max())
        
        # Bordes de Laplacian para detalles finos
        laplacian = cv2.Laplacian(gray_enhanced, cv2.CV_64F)
        laplacian_abs = np.uint8(np.absolute(laplacian))
        
        # 3. COMBINAR TODOS LOS BORDES para crear una imagen de relieves completa
        edges_combined = cv2.addWeighted(edges_canny, 0.4, sobel_normalized, 0.4, 0)
        edges_combined = cv2.addWeighted(edges_combined, 0.8, laplacian_abs, 0.2, 0)
        
        # 4. UMBRALIZACIÓN ADAPTATIVA para resaltar patrones únicos
        thresh_adaptive = cv2.adaptiveThreshold(gray_enhanced, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)
        
        # 5. MORFOLOGÍA para limpiar y conectar patrones
        kernel = np.ones((2,2), np.uint8)
        edges_morph = cv2.morphologyEx(edges_combined, cv2.MORPH_CLOSE, kernel)
        
        # 6. COMBINAR IMAGEN ORIGINAL CON RELIEVES RESALTADOS
        # Convertir bordes a escala de grises
        edges_gray = cv2.cvtColor(edges_morph, cv2.COLOR_GRAY2RGB)
        thresh_gray = cv2.cvtColor(thresh_adaptive, cv2.COLOR_GRAY2RGB)
        
        # Mezcla inteligente: 60% imagen original + 40% relieves resaltados
        enhanced = cv2.addWeighted(img_float, 0.6, edges_gray.astype(np.float32) / 255.0, 0.4, 0)
        
        # 7. NORMALIZACIÓN FINAL
        enhanced = np.clip(enhanced, 0, 1)
        
        # 8. CONVERTIR A BLANCO Y NEGRO CON ALTO CONTRASTE
        enhanced_gray = cv2.cvtColor(enhanced, cv2.COLOR_RGB2GRAY)
        enhanced_gray = cv2.equalizeHist(np.uint8(enhanced_gray * 255))
        
        # 9. APLICAR UMBRAL FINAL para crear imagen binaria de alta calidad
        _, final_binary = cv2.threshold(enhanced_gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        
        # 10. CONVERTIR DE VUELTA A RGB (blanco y negro)
        final_rgb = cv2.cvtColor(final_binary, cv2.COLOR_GRAY2RGB)
        
        return final_rgb.astype(np.float32) / 255.0
    
    def extract_nose_features(self, img_bytes: bytes) -> Dict[str, List[float]]:
        """Extraer características específicas de huella nasal"""
        try:
            if not self.feature_models:
                logger.warning("Modelos no disponibles, usando características tradicionales")
                return {'traditional': self._extract_nose_traditional_features(img_bytes)}
            
            processed_images = self.preprocess_nose_image(img_bytes)
            features = {}
            
            # Extraer características de cada modelo
            for model_name, model in self.feature_models.items():
                if model_name in processed_images:
                    img_array = processed_images[model_name]
                    model_features = model.predict(img_array, verbose=0)
                    
                    # Normalizar características
                    features_norm = model_features[0] / np.linalg.norm(model_features[0])
                    features[model_name] = features_norm.tolist()
            
            # Agregar características específicas de nariz
            features['nose_specific'] = self._extract_nose_specific_features(img_bytes)
            
            logger.info(f"Características de nariz extraídas de {len(features)} fuentes")
            return features
            
        except Exception as e:
            logger.error(f"Error en extracción de características de nariz: {e}")
            return {'traditional': self._extract_nose_traditional_features(img_bytes)}
    
    def _extract_nose_specific_features(self, img_bytes: bytes) -> List[float]:
        """Extraer características específicas de la nariz incluyendo manchas y patrones únicos"""
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_UNCHANGED)
        
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
        
        # Manejar imágenes con canal alfa (RGBA)
        if img.shape[-1] == 4:  # RGBA
            # Convertir RGBA a RGB usando fondo blanco
            alpha = img[:, :, 3] / 255.0
            rgb = img[:, :, :3].astype(np.float32)
            white_background = np.ones_like(rgb) * 255
            img = (rgb * alpha[:, :, np.newaxis] + white_background * (1 - alpha[:, :, np.newaxis])).astype(np.uint8)
        elif img.shape[-1] == 3:  # BGR
            # Convertir BGR a RGB
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        else:
            # Convertir escala de grises a RGB
            img = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)
        img = cv2.resize(img, (224, 224))
        
        features = []
        
        # Convertir a escala de grises
        gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        gray_uint8 = np.clip(gray.astype(np.float32) * 255, 0, 255).astype(np.uint8)
        
        # MEJORA: Detección de manchas y características únicas
        # Detectar manchas usando umbral adaptativo
        thresh = cv2.adaptiveThreshold(gray_uint8, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 11, 2)
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        # Características de manchas
        spot_features = []
        if contours:
            # Encontrar las manchas más grandes
            areas = [cv2.contourArea(c) for c in contours]
            if areas:
                max_area = max(areas)
                spot_features.extend([
                    len(contours),  # Número de manchas
                    max_area / (224 * 224),  # Área de la mancha más grande
                    sum(areas) / (224 * 224),  # Área total de manchas
                    np.mean(areas) if areas else 0  # Área promedio
                ])
            else:
                spot_features = [0, 0, 0, 0]
        else:
            spot_features = [0, 0, 0, 0]
        
        features.extend(spot_features)
        
        # Características específicas de textura de nariz
        # Histograma de gradientes
        grad_x = cv2.Sobel(gray_uint8, cv2.CV_64F, 1, 0, ksize=3)
        grad_y = cv2.Sobel(gray_uint8, cv2.CV_64F, 0, 1, ksize=3)
        magnitude = np.sqrt(grad_x**2 + grad_y**2)
        angle = np.arctan2(grad_y, grad_x)
        
        # Histograma de gradientes (HOG simplificado)
        hist_mag = np.histogram(magnitude, bins=16, range=(0, np.max(magnitude)))[0]
        hist_angle = np.histogram(angle, bins=16, range=(-np.pi, np.pi))[0]
        
        features.extend(hist_mag / np.sum(hist_mag))
        features.extend(hist_angle / np.sum(hist_angle))
        
        # Características de textura local
        # Matriz de co-ocurrencia simplificada
        for i in range(0, 224, 32):
            for j in range(0, 224, 32):
                patch = gray_uint8[i:i+32, j:j+32]
                if patch.size > 0:
                    features.extend([
                        float(np.mean(patch)),
                        float(np.std(patch)),
                        float(np.max(patch)),
                        float(np.min(patch))
                    ])
        
        # Características de forma de la nariz
        # Detectar contornos
        edges = cv2.Canny(gray_uint8, 50, 150)
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        if contours:
            # Encontrar el contorno más grande (probablemente la nariz)
            largest_contour = max(contours, key=cv2.contourArea)
            area = cv2.contourArea(largest_contour)
            perimeter = cv2.arcLength(largest_contour, True)
            
            features.extend([
                float(area / (224 * 224)),  # Área normalizada
                float(perimeter / (2 * (224 + 224))),  # Perímetro normalizado
                float(area / (perimeter * perimeter)) if perimeter > 0 else 0  # Circularidad
            ])
        else:
            features.extend([0.0, 0.0, 0.0])
        
        # Normalización L2
        features_norm = np.array(features)
        features_norm = features_norm / np.linalg.norm(features_norm)
        
        return features_norm.tolist()
    
    def _extract_nose_traditional_features(self, img_bytes: bytes) -> List[float]:
        """Extraer características tradicionales específicas para nariz"""
        nparr = np.frombuffer(img_bytes, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_UNCHANGED)
        
        if img is None:
            raise ValueError("No se pudo decodificar la imagen")
        
        # Manejar imágenes con canal alfa (RGBA)
        if img.shape[-1] == 4:  # RGBA
            # Convertir RGBA a RGB usando fondo blanco
            alpha = img[:, :, 3] / 255.0
            rgb = img[:, :, :3].astype(np.float32)
            white_background = np.ones_like(rgb) * 255
            img = (rgb * alpha[:, :, np.newaxis] + white_background * (1 - alpha[:, :, np.newaxis])).astype(np.uint8)
        elif img.shape[-1] == 3:  # BGR
            # Convertir BGR a RGB
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        else:
            # Convertir escala de grises a RGB
            img = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)
        img = cv2.resize(img, (224, 224))
        
        features = []
        
        # Convertir a escala de grises
        gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        gray_uint8 = np.clip(gray.astype(np.float32) * 255, 0, 255).astype(np.uint8)
        
        # Histograma mejorado
        hist = cv2.calcHist([gray_uint8], [0], None, [256], [0, 256])
        hist = hist.flatten() / hist.sum()
        features.extend(hist.tolist())
        
        # Características de textura avanzadas
        grad_x = cv2.Sobel(gray_uint8, cv2.CV_64F, 1, 0, ksize=3)
        grad_y = cv2.Sobel(gray_uint8, cv2.CV_64F, 0, 1, ksize=3)
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
        
        # Características de color específicas para nariz
        for channel in range(3):
            channel_img = img[:,:,channel]
            features.extend([
                float(np.mean(channel_img)),
                float(np.std(channel_img)),
                float(np.max(channel_img)),
                float(np.min(channel_img)),
                float(np.median(channel_img))
            ])
        
        # Momentos de imagen
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
                logger.info(f"Cargados {len(self.embeddings)} embeddings de huella nasal")
        else:
            self.embeddings = {}
            logger.info("No se encontraron embeddings de huella nasal previos")
    
    def save_embeddings(self):
        """Guardar embeddings"""
        with open(self.embeddings_path, 'w') as f:
            json.dump(self.embeddings, f)
        logger.info(f"Guardados {len(self.embeddings)} embeddings de huella nasal")
    
    def register_nose_print(self, pet_id: str, img_bytes: bytes) -> Dict:
        """Registrar una nueva huella nasal"""
        try:
            features = self.extract_nose_features(img_bytes)
            
            # Convertir numpy arrays a listas para serialización JSON
            features_serializable = {}
            for model_name, model_features in features.items():
                features_serializable[model_name] = [float(f) for f in model_features]
            
            self.embeddings[pet_id] = features_serializable
            self.save_embeddings()
            
            total_features = sum(len(f) for f in features_serializable.values())
            logger.info(f"Huella nasal de mascota {pet_id} registrada exitosamente")
            logger.info(f"Total de características: {total_features}")
            
            return {
                "status": "success", 
                "pet_id": pet_id, 
                "models_used": list(features_serializable.keys()),
                "total_features": total_features
            }
            
        except Exception as e:
            logger.error(f"Error registrando huella nasal de mascota {pet_id}: {str(e)}")
            return {"status": "error", "message": str(e)}
    
    def compare_nose_print(self, img_bytes: bytes) -> Dict:
        """Comparar huella nasal con mejor manejo de variaciones"""
        try:
            # Convertir bytes a imagen
            nparr = np.frombuffer(img_bytes, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_UNCHANGED)
            
            if img is None:
                raise ValueError("No se pudo decodificar la imagen")
            
            # Manejar imágenes con canal alfa (RGBA)
            if img.shape[-1] == 4:  # RGBA
                # Convertir RGBA a RGB usando fondo blanco
                alpha = img[:, :, 3] / 255.0
                rgb = img[:, :, :3].astype(np.float32)
                white_background = np.ones_like(rgb) * 255
                img = (rgb * alpha[:, :, np.newaxis] + white_background * (1 - alpha[:, :, np.newaxis])).astype(np.uint8)
            elif img.shape[-1] == 3:  # BGR
                # Convertir BGR a RGB
                img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            else:
                # Convertir escala de grises a RGB
                img = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)
            
            # Extraer características directamente de los bytes
            features = self.extract_nose_features(img_bytes)
            
            if not self.embeddings:
                return {
                    "match": False,
                    "confidence": 0.0,
                    "message": "No hay mascotas registradas",
                    "all_similarities": {}
                }
            
            # Calcular similitudes con pesos ajustados para detectar características únicas
            similarities = {}
            model_weights = {
                'mobilenet': 0.35,      # Características generales
                'efficientnet': 0.35,   # Características específicas
                'nose_specific': 0.30   # MAYOR PESO para manchas y patrones únicos
            }
            
            for pet_id, stored_features in self.embeddings.items():
                model_scores = {}
                weighted_score = 0.0
                
                for model_name in model_weights.keys():
                    if model_name in features and model_name in stored_features:
                        similarity = self.cosine_similarity_nose(
                            features[model_name], stored_features[model_name]
                        )
                        model_scores[model_name] = similarity
                        weighted_score += similarity * model_weights[model_name]
                
                similarities[pet_id] = {
                    'final_score': weighted_score,
                    'model_scores': model_scores
                }
            
            # Encontrar la mejor coincidencia
            if similarities:
                best_match = max(similarities.items(), key=lambda x: x[1]['final_score'])
                best_pet_id, best_score_data = best_match
                final_score = best_score_data['final_score']
                
                # Aplicar boost de confianza
                confidence = min(1.0, final_score * self.confidence_boost)
                
                # Verificar si supera el umbral
                is_match = confidence >= self.threshold
                
                return {
                    "match": bool(is_match),
                    "confidence": float(confidence),
                    "raw_score": float(final_score),
                    "petId": str(best_pet_id) if is_match else None,
                    "message": f"Huella nasal {'coincidente' if is_match else 'no coincidente'} encontrada con confianza {confidence*100:.1f}%",
                    "all_similarities": {str(k): {"final_score": float(v["final_score"]), "model_scores": {str(mk): float(mv) for mk, mv in v["model_scores"].items()}} for k, v in similarities.items()}
                }
            
            return {
                "match": False,
                "confidence": 0.0,
                "message": "No se encontraron coincidencias",
                "all_similarities": {str(k): {"final_score": float(v["final_score"]), "model_scores": {str(mk): float(mv) for mk, mv in v["model_scores"].items()}} for k, v in similarities.items()}
            }
            
        except Exception as e:
            return {
                "match": False,
                "confidence": 0.0,
                "message": f"Error en comparación: {str(e)}",
                "all_similarities": {}
            }
    
    def cosine_similarity_nose(self, a: List[float], b: List[float]) -> float:
        """Calcular similitud coseno para huellas nasales"""
        a = np.array(a)
        b = np.array(b)
        
        # Verificar que los vectores no sean cero
        if np.linalg.norm(a) == 0 or np.linalg.norm(b) == 0:
            return 0.0
        
        return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
    
    def get_model_stats(self) -> Dict:
        """Obtener estadísticas del modelo de huella nasal"""
        return {
            "total_pets": len(self.embeddings),
            "embeddings_path": self.embeddings_path,
            "threshold": self.threshold,
            "confidence_boost": self.confidence_boost,
            "model_type": "NosePrintRecognitionModel",
            "available_models": list(self.feature_models.keys()),
            "model_weights": {
                'mobilenet': 0.35,
                'efficientnet': 0.40,
                'nose_specific': 0.25
            }
        }
    
    def update_threshold(self, new_threshold: float):
        """Actualizar umbral de similitud"""
        if 0.0 <= new_threshold <= 1.0:
            self.threshold = new_threshold
            logger.info(f"Umbral de huella nasal actualizado a: {new_threshold}")
        else:
            raise ValueError("Threshold must be between 0.0 and 1.0")
    
    def update_confidence_boost(self, new_boost: float):
        """Actualizar factor de boost de confianza"""
        if new_boost > 0:
            self.confidence_boost = new_boost
            logger.info(f"Confidence boost de huella nasal actualizado a: {new_boost}")
        else:
            raise ValueError("Confidence boost must be positive") 