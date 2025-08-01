#!/usr/bin/env python3
"""
Script para regenerar embeddings usando las imágenes reales de cada mascota
"""

import requests
import json
import os
from typing import Dict, List
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_all_pets() -> List[Dict]:
    """Obtener todas las mascotas del pet-service"""
    try:
        response = requests.get("http://localhost:8083/pets", timeout=10)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Error obteniendo mascotas: {response.status_code}")
            return []
    except Exception as e:
        print(f"Error conectando al pet-service: {e}")
        return []

def download_pet_image(image_url: str, pet_id: str) -> bytes:
    """Descargar imagen de la mascota desde GCS"""
    try:
        response = requests.get(image_url, timeout=30)
        if response.status_code == 200:
            return response.content
        else:
            print(f"Error descargando imagen para {pet_id}: {response.status_code}")
            return None
    except Exception as e:
        print(f"Error descargando imagen para {pet_id}: {e}")
        return None

def register_embedding(pet_id: str, image_bytes: bytes) -> bool:
    """Registrar embedding en el AI Service"""
    try:
        files = {'image': ('nose.jpg', image_bytes, 'image/jpeg')}
        
        response = requests.post(
            f"http://localhost:8000/register-embedding?petId={pet_id}",
            files=files,
            timeout=30
        )
        
        if response.status_code == 200:
            print(f"✅ Embedding registrado para {pet_id}")
            return True
        else:
            print(f"❌ Error registrando embedding para {pet_id}: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Error registrando embedding para {pet_id}: {e}")
        return False

def main():
    """Función principal"""
    print("🔄 Regenerando embeddings con imágenes reales...")
    
    # Obtener todas las mascotas
    pets = get_all_pets()
    if not pets:
        print("❌ No se pudieron obtener las mascotas")
        return
    
    print(f"📊 Encontradas {len(pets)} mascotas")
    
    # Filtrar mascotas con imágenes de nariz
    pets_with_nose_images = [pet for pet in pets if pet.get('noseImageUrl')]
    print(f"📸 {len(pets_with_nose_images)} mascotas tienen imágenes de nariz")
    
    # Limpiar embeddings existentes
    print("🧹 Limpiando embeddings existentes...")
    if os.path.exists("nose_print_embeddings.json"):
        os.remove("nose_print_embeddings.json")
        print("✅ Embeddings anteriores eliminados")
    
    # Registrar embeddings con imágenes reales
    success_count = 0
    for pet in pets_with_nose_images:
        pet_id = pet['id']
        pet_name = pet['name']
        nose_image_url = pet['noseImageUrl']
        
        print(f"\n🔄 Procesando {pet_name} (ID: {pet_id})")
        print(f"📸 URL: {nose_image_url}")
        
        # Descargar imagen
        image_bytes = download_pet_image(nose_image_url, pet_id)
        if image_bytes is None:
            print(f"❌ No se pudo descargar imagen para {pet_name}")
            continue
        
        # Registrar embedding
        if register_embedding(pet_id, image_bytes):
            success_count += 1
        else:
            print(f"❌ No se pudo registrar embedding para {pet_name}")
    
    print(f"\n🎉 Proceso completado!")
    print(f"✅ {success_count} embeddings registrados exitosamente")
    print(f"❌ {len(pets_with_nose_images) - success_count} errores")

if __name__ == "__main__":
    main() 