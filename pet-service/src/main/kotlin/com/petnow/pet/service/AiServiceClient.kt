package com.petnow.pet.service

import java.util.*
import org.springframework.beans.factory.annotation.Value
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.stereotype.Service
import org.springframework.util.LinkedMultiValueMap
import org.springframework.web.client.RestTemplate
import org.springframework.web.multipart.MultipartFile

@Service
class AiServiceClient {
    private val restTemplate = RestTemplate()

    @Value("\${ai.service.url:http://192.168.0.104:8000}") private lateinit var aiServiceUrl: String

    @Value("\${ai.service.enabled:true}") private var aiServiceEnabled: Boolean = true

    fun registerEmbedding(petId: String, noseImage: MultipartFile): Boolean {
        if (!aiServiceEnabled) {
            println("AI Service is disabled, skipping embedding registration for pet $petId")
            return true
        }

        try {
            println("=== AI SERVICE CLIENT DEBUG ===")
            println("Pet ID: $petId")
            println("AI Service URL: $aiServiceUrl")
            println("Image filename: ${noseImage.originalFilename}")
            println("Image size: ${noseImage.size} bytes")
            println("Image content type: ${noseImage.contentType}")

            val headers = HttpHeaders()
            headers.contentType = MediaType.MULTIPART_FORM_DATA
            println("Headers: $headers")

            val body = LinkedMultiValueMap<String, Any>()
            body.add("image", noseImage.resource)
            println("Body keys: ${body.keys}")
            println("Body size: ${body.size}")

            val request = HttpEntity(body, headers)
            val fullUrl = "$aiServiceUrl/register-embedding?petId=$petId"
            println("Full URL: $fullUrl")

            println("Sending request to AI Service...")
            val response = restTemplate.postForObject(fullUrl, request, Map::class.java)

            println("Response received: $response")
            println("Response type: ${response?.javaClass?.simpleName}")
            println("=== END AI SERVICE CLIENT DEBUG ===")

            return true
        } catch (e: Exception) {
            println("=== AI SERVICE CLIENT ERROR ===")
            println("Error registering embedding for pet $petId")
            println("Exception type: ${e.javaClass.simpleName}")
            println("Error message: ${e.message}")
            println("Stack trace:")
            e.printStackTrace()
            println("=== END AI SERVICE CLIENT ERROR ===")
            // No lanzar excepción, solo log del error para no romper el flujo principal
            return false
        }
    }

    fun scanImage(image: MultipartFile): Map<String, Any> {
        if (!aiServiceEnabled) {
            println("AI Service is disabled, returning mock scan result")
            return mapOf(
                    "match" to false,
                    "confidence" to 0.0,
                    "message" to "AI Service is disabled"
            )
        }

        try {
            println("=== AI SERVICE SCAN CLIENT DEBUG ===")
            println("AI Service URL: $aiServiceUrl")
            println("Image filename: ${image.originalFilename}")
            println("Image size: ${image.size} bytes")

            val headers = HttpHeaders()
            headers.contentType = MediaType.MULTIPART_FORM_DATA

            val body = LinkedMultiValueMap<String, Any>()
            body.add("image", image.resource)

            val request = HttpEntity(body, headers)
            val fullUrl = "$aiServiceUrl/scan"
            println("Full URL: $fullUrl")

            println("Sending scan request to AI Service...")
            val response = restTemplate.postForObject(fullUrl, request, Map::class.java)

            println("Scan response received: $response")
            println("=== END AI SERVICE SCAN CLIENT DEBUG ===")

            return response?.let { @Suppress("UNCHECKED_CAST") it as Map<String, Any> }
                    ?: mapOf(
                            "match" to false,
                            "confidence" to 0.0,
                            "error" to "No response from AI Service"
                    )
        } catch (e: Exception) {
            println("=== AI SERVICE SCAN CLIENT ERROR ===")
            println("Error scanning image")
            println("Exception type: ${e.javaClass.simpleName}")
            println("Error message: ${e.message}")
            e.printStackTrace()
            println("=== END AI SERVICE SCAN CLIENT ERROR ===")

            return mapOf(
                    "match" to false,
                    "confidence" to 0.0,
                    "error" to (e.message ?: "Unknown error")
            )
        }
    }

    fun visualComparison(image: MultipartFile): Map<String, Any> {
        if (!aiServiceEnabled) {
            println("AI Service is disabled, returning mock visual comparison result")
            return mapOf(
                    "uploaded_image_features" to emptyMap<String, Any>(),
                    "registered_pets_comparison" to emptyList<Map<String, Any>>(),
                    "top_matches" to emptyList<Map<String, Any>>(),
                    "analysis_summary" to
                            mapOf(
                                    "total_pets_compared" to 0,
                                    "matching_pets" to 0,
                                    "best_match_score" to 0.0,
                                    "threshold_used" to 0.0,
                                    "confidence_boost" to 0.0,
                                    "feature_models_used" to emptyList<String>()
                            )
            )
        }

        try {
            println("=== AI SERVICE VISUAL COMPARISON CLIENT DEBUG ===")
            println("AI Service URL: $aiServiceUrl")
            println("Image filename: ${image.originalFilename}")
            println("Image size: ${image.size} bytes")

            val headers = HttpHeaders()
            headers.contentType = MediaType.MULTIPART_FORM_DATA

            val body = LinkedMultiValueMap<String, Any>()
            body.add("image", image.resource)

            val request = HttpEntity(body, headers)
            val fullUrl = "$aiServiceUrl/visual-comparison"
            println("Full URL: $fullUrl")

            println("Sending visual comparison request to AI Service...")
            val response = restTemplate.postForObject(fullUrl, request, Map::class.java)

            println("Visual comparison response received: $response")
            println("=== END AI SERVICE VISUAL COMPARISON CLIENT DEBUG ===")

            return response?.let { @Suppress("UNCHECKED_CAST") it as Map<String, Any> }
                    ?: mapOf(
                            "error" to "No response from AI Service",
                            "uploaded_image_features" to emptyMap<String, Any>(),
                            "registered_pets_comparison" to emptyList<Map<String, Any>>(),
                            "top_matches" to emptyList<Map<String, Any>>(),
                            "analysis_summary" to emptyMap<String, Any>()
                    )
        } catch (e: Exception) {
            println("=== AI SERVICE VISUAL COMPARISON CLIENT ERROR ===")
            println("Error in visual comparison")
            println("Exception type: ${e.javaClass.simpleName}")
            println("Error message: ${e.message}")
            e.printStackTrace()
            println("=== END AI SERVICE VISUAL COMPARISON CLIENT ERROR ===")

            return mapOf(
                    "error" to (e.message ?: "Unknown error"),
                    "uploaded_image_features" to emptyMap<String, Any>(),
                    "registered_pets_comparison" to emptyList<Map<String, Any>>(),
                    "top_matches" to emptyList<Map<String, Any>>(),
                    "analysis_summary" to emptyMap<String, Any>()
            )
        }
    }
}
