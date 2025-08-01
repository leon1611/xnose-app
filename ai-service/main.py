# Servicio de IA para reconocimiento de huellas nasales de mascotas
from fastapi import FastAPI, File, UploadFile, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random
import uuid
from typing import Optional, List
import numpy as np
import cv2
import tensorflow as tf
import os
import json
import requests
from simple_nose_model import SimpleNoseModel
from advanced_nose_model import AdvancedNoseModel
from nose_print_model import NosePrintModel
import logging
import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="AI Service - PETNOW-DOGS",
    description="AI service for PETNOW-DOGS - Advanced nose print recognition with training capabilities",
    version="2.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ScanResponse(BaseModel):
    match: bool
    petId: Optional[str] = None
    confidence: float
    message: Optional[str] = None
    all_similarities: Optional[dict] = None

class VisualComparisonResponse(BaseModel):
    uploaded_image_features: dict
    registered_pets_comparison: List[dict]
    top_matches: List[dict]
    analysis_summary: dict

class TrainingRequest(BaseModel):
    pet_ids: List[str]
    epochs: Optional[int] = 10

class TrainingResponse(BaseModel):
    status: str
    message: str
    training_data_count: int
    epochs: int

# Inicializar modelos
simple_model = SimpleNoseModel()
simple_model.load_embeddings()

# Inicializar modelo avanzado
advanced_model = AdvancedNoseModel()
advanced_model.load_embeddings()

# Inicializar modelo específico de huella nasal
nose_print_model = NosePrintModel()
nose_print_model.load_embeddings()

# Usar modelo de huella nasal por defecto (más preciso para narices)
nose_model = nose_print_model

AUDIT_LOG = "requests.log"

def log_audit(event: str, data: dict):
    """Registrar evento de auditoría en archivo"""
    entry = {
        "timestamp": datetime.datetime.now().isoformat(),
        "event": event,
        **data
    }
    with open(AUDIT_LOG, "a") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

@app.post("/register-embedding")
async def register_embedding(petId: str, image: UploadFile = File(...)):
    """Registrar una nueva mascota con su huella nasal usando modelo específico"""
    log_audit("register-embedding-request", {
        "petId": petId,
        "filename": image.filename,
        "content_type": image.content_type
    })
    if not image.content_type or not image.content_type.startswith("image/"):
        log_audit("register-embedding-error", {"petId": petId, "error": "File must be an image"})
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        img_bytes = await image.read()
        
        # Usar modelo específico de huella nasal
        result = nose_print_model.register_nose_print(petId, img_bytes)
        
        # También registrar en otros modelos para compatibilidad
        advanced_result = advanced_model.register_pet_advanced(petId, img_bytes)
        simple_result = simple_model.register_pet(petId, img_bytes)
        
        log_audit("register-embedding-result", {
            "petId": petId,
            "result": result,
            "advanced_result": advanced_result,
            "simple_result": simple_result,
            "img_size": len(img_bytes)
        })
        
        if result["status"] == "success":
            return {
                "status": "registered", 
                "petId": petId,
                "models_used": result.get("models_used", []),
                "total_features": result.get("total_features", 0),
                "total_pets": len(nose_print_model.embeddings),
                "message": "Huella nasal registrada exitosamente"
            }
        else:
            log_audit("register-embedding-error", {"petId": petId, "error": result["message"]})
            raise HTTPException(status_code=500, detail=result["message"])
            
    except Exception as e:
        log_audit("register-embedding-exception", {"petId": petId, "error": str(e)})
        logger.error(f"Error registering pet {petId}: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/compare", response_model=ScanResponse)
async def compare_nose_print(image: UploadFile = File(...)):
    """Comparar huella nasal con todas las mascotas registradas usando modelo específico"""
    log_audit("compare-request", {
        "filename": image.filename,
        "content_type": image.content_type
    })
    if not image.content_type or not image.content_type.startswith("image/"):
        log_audit("compare-error", {"error": "File must be an image"})
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        img_bytes = await image.read()
        
        # Usar modelo específico de huella nasal
        result = nose_print_model.compare_nose_print(img_bytes)
        
        log_audit("compare-result", {
            "result": result,
            "img_size": len(img_bytes)
        })
        
        return ScanResponse(
            match=result["match"],
            petId=result.get("pet_id"),
            confidence=result["confidence"],
            message=result.get("message"),
            all_similarities=result.get("all_similarities")
        )
        
    except Exception as e:
        log_audit("compare-exception", {"error": str(e)})
        logger.error(f"Error comparing nose: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/train-model", response_model=TrainingResponse)
async def train_model(request: TrainingRequest, background_tasks: BackgroundTasks):
    """Endpoint de entrenamiento (no implementado en modelo simple)"""
    return TrainingResponse(
        status="not_implemented",
        message="El entrenamiento no está disponible en el modelo simple",
        training_data_count=0,
        epochs=request.epochs or 10
    )

@app.get("/model-stats")
async def get_model_stats():
    """Obtener estadísticas del modelo avanzado"""
    return {
        "advanced_model": advanced_model.get_model_stats(),
        "simple_model": simple_model.get_model_stats(),
        "active_model": "advanced"
    }

@app.post("/update-threshold")
async def update_threshold(threshold: float):
    """Actualizar umbral de similitud"""
    if 0.0 <= threshold <= 1.0:
        # Actualizar todos los modelos
        nose_print_model.update_threshold(threshold)
        advanced_model.update_threshold(threshold)
        simple_model.threshold = threshold
        return {"status": "updated", "new_threshold": threshold}
    else:
        raise HTTPException(status_code=400, detail="Threshold must be between 0.0 and 1.0")

@app.post("/update-confidence-boost")
async def update_confidence_boost(boost: float):
    """Actualizar factor de boost de confianza"""
    if boost > 0:
        # Actualizar todos los modelos
        nose_print_model.update_confidence_boost(boost)
        advanced_model.update_confidence_boost(boost)
        return {"status": "updated", "new_confidence_boost": boost}
    else:
        raise HTTPException(status_code=400, detail="Confidence boost must be positive")

@app.post("/scan")
async def scan_nose_print(image: UploadFile = File(...)):
    """Endpoint unificado para escanear huella nasal usando modelo específico"""
    log_audit("scan-request", {
        "filename": image.filename,
        "content_type": image.content_type
    })
    
    if not image.content_type or not image.content_type.startswith("image/"):
        log_audit("scan-error", {"error": "File must be an image"})
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        img_bytes = await image.read()
        
        # Usar modelo específico de huella nasal
        result = nose_print_model.compare_nose_print(img_bytes)
        
        log_audit("scan-result", {
            "result": result,
            "img_size": len(img_bytes)
        })
        
        # Obtener información de la mascota si hay coincidencia
        petName = None
        petId = result.get("petId") or result.get("pet_id")
        if result["match"] and petId:
            try:
                # Obtener información de la mascota desde el pet-service
                pet_response = requests.get(f"http://localhost:8083/pets/{petId}", timeout=5)
                if pet_response.status_code == 200:
                    pet_data = pet_response.json()
                    petName = pet_data.get("name", "Mascota Encontrada")
                else:
                    logger.warning(f"Pet service returned {pet_response.status_code}")
                    petName = "Mascota Encontrada"
            except Exception as e:
                logger.warning(f"Could not fetch pet info: {str(e)}")
                petName = "Mascota Encontrada"
        
        # Formato de respuesta compatible con el frontend
        return {
            "match": result["match"],
            "petId": petId,  # Usar el petId ya extraído
            "petName": petName,
            "confidence": result["confidence"],
            "raw_score": result.get("raw_score", result["confidence"]),
            "message": result.get("message"),
            "all_similarities": result.get("all_similarities")
        }
        
    except Exception as e:
        log_audit("scan-exception", {"error": str(e)})
        logger.error(f"Error scanning nose: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/visual-comparison")
async def visual_comparison(image: UploadFile = File(...)):
    """Endpoint para comparación visual detallada de huella nasal"""
    log_audit("visual-comparison-request", {
        "filename": image.filename,
        "content_type": image.content_type
    })
    
    if not image.content_type or not image.content_type.startswith("image/"):
        log_audit("visual-comparison-error", {"error": "File must be an image"})
        raise HTTPException(status_code=400, detail="File must be an image")
    
    try:
        img_bytes = await image.read()
        
        # Extraer características de la imagen subida
        uploaded_features = nose_print_model.extract_nose_features(img_bytes)
        
        # Obtener comparaciones con todas las mascotas registradas
        all_similarities = nose_print_model.compare_nose_print(img_bytes)
        
        # Preparar respuesta detallada
        registered_pets_comparison = []
        top_matches = []
        
        if "all_similarities" in all_similarities:
            for pet_id, similarity_data in all_similarities["all_similarities"].items():
                pet_info = {
                    "petId": pet_id,
                    "final_score": similarity_data.get("final_score", 0),
                    "model_scores": similarity_data.get("model_scores", {}),
                    "match": similarity_data.get("final_score", 0) >= nose_print_model.threshold
                }
                
                # Obtener información de la mascota
                try:
                    pet_response = requests.get(f"http://localhost:8083/pets/{pet_id}", timeout=5)
                    if pet_response.status_code == 200:
                        pet_data = pet_response.json()
                        pet_info["petName"] = pet_data.get("name", "Mascota Desconocida")
                        pet_info["breed"] = pet_data.get("breed", "Desconocida")
                        pet_info["noseImageUrl"] = pet_data.get("noseImageUrl")
                    else:
                        pet_info["petName"] = "Mascota Desconocida"
                        pet_info["breed"] = "Desconocida"
                except Exception as e:
                    logger.warning(f"Could not fetch pet info for {pet_id}: {str(e)}")
                    pet_info["petName"] = "Mascota Desconocida"
                    pet_info["breed"] = "Desconocida"
                
                registered_pets_comparison.append(pet_info)
                
                # Agregar a top matches si supera el umbral
                if pet_info["match"]:
                    top_matches.append(pet_info)
        
        # Ordenar por score
        registered_pets_comparison.sort(key=lambda x: x["final_score"], reverse=True)
        top_matches.sort(key=lambda x: x["final_score"], reverse=True)
        
        # Análisis resumido
        analysis_summary = {
            "total_pets_compared": len(registered_pets_comparison),
            "matching_pets": len(top_matches),
            "best_match_score": registered_pets_comparison[0]["final_score"] if registered_pets_comparison else 0,
            "threshold_used": nose_print_model.threshold,
            "confidence_boost": nose_print_model.confidence_boost,
            "feature_models_used": list(uploaded_features.keys())
        }
        
        return {
            "uploaded_image_features": {
                "feature_models": list(uploaded_features.keys()),
                "feature_dimensions": {model: len(features) for model, features in uploaded_features.items()}
            },
            "registered_pets_comparison": registered_pets_comparison,
            "top_matches": top_matches,
            "analysis_summary": analysis_summary
        }
        
    except Exception as e:
        log_audit("visual-comparison-exception", {"error": str(e)})
        logger.error(f"Error in visual comparison: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "nose_print_model_loaded": len(nose_print_model.feature_models) > 0,
        "advanced_model_loaded": len(advanced_model.feature_models) > 0,
        "simple_model_loaded": True,
        "total_pets_nose_print": len(nose_print_model.embeddings),
        "total_pets_advanced": len(advanced_model.embeddings),
        "total_pets_simple": len(simple_model.embeddings),
        "threshold": nose_print_model.threshold,
        "confidence_boost": nose_print_model.confidence_boost,
        "active_model": "nose_print",
        "available_models": list(nose_print_model.feature_models.keys())
    }

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "AI Service for PETNOW-DOGS - Advanced Multi-Model Nose Recognition",
        "version": "3.0.0",
        "endpoints": {
            "health": "/health",
            "register": "/register-embedding",
            "compare": "/compare",
            "scan": "/scan",
            "train": "/train-model",
            "stats": "/model-stats",
            "threshold": "/update-threshold",
            "confidence_boost": "/update-confidence-boost"
        },
        "features": [
            "Multi-model architecture (MobileNetV2 + EfficientNetB0 + Traditional)",
            "Advanced image preprocessing with CLAHE and bilateral filtering",
            "Weighted ensemble scoring for better accuracy",
            "Configurable confidence boost for optimal detection",
            "Enhanced feature extraction with texture and shape analysis",
            "Real-time nose print recognition with high precision"
        ],
        "models": {
            "advanced": "Multi-model ensemble with deep learning",
            "simple": "Traditional feature-based model (backup)"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 