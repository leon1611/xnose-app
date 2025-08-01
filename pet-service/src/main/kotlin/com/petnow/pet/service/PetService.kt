package com.petnow.pet.service

import com.petnow.pet.dto.CreatePetRequest
import com.petnow.pet.dto.PetResponse
import com.petnow.pet.dto.UpdatePetRequest
import com.petnow.pet.entity.Pet
import com.petnow.pet.repository.PetRepository
import java.time.LocalDateTime
import java.util.*
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile

@Service
class PetService(
        private val petRepository: PetRepository,
        @Autowired private val gcsService: GcsService,
        @Autowired private val aiServiceClient: AiServiceClient
) {

    fun getAllPets(): List<PetResponse> {
        return petRepository.findAll().map { it.toResponse() }
    }

    fun getPetsByUserId(userId: Long): List<PetResponse> {
        return petRepository.findByUserId(userId).map { it.toResponse() }
    }

    fun getPetById(id: UUID): PetResponse {
        val pet =
                petRepository.findById(id).orElseThrow {
                    RuntimeException("Pet not found with id: $id")
                }
        return pet.toResponse()
    }

    fun getPetsByOwnerId(ownerId: UUID): List<PetResponse> {
        return petRepository.findByOwnerId(ownerId).map { it.toResponse() }
    }

    fun createPet(request: CreatePetRequest, userId: Long): PetResponse {
        val pet =
                Pet(
                        name = request.name,
                        breed = request.breed,
                        age = request.age,
                        sex = request.sex,
                        ownerId = request.ownerId,
                        userId = userId
                )

        val savedPet = petRepository.save(pet)
        return savedPet.toResponse()
    }

    fun createPetWithImages(
            request: CreatePetRequest,
            profileImage: MultipartFile?,
            noseImage: MultipartFile?,
            userId: Long
    ): PetResponse {
        var profileImageUrl: String? = null
        var noseImageUrl: String? = null

        if (profileImage != null && !profileImage.isEmpty) {
            // Subir imagen de perfil usando GcsService
            try {
                profileImageUrl = gcsService.uploadFile(profileImage, "profiles")
                println("Profile image uploaded successfully: $profileImageUrl")
            } catch (e: Exception) {
                println("Failed to upload profile image: ${e.message}")
                // Continuar sin imagen de perfil
            }
        }

        if (noseImage != null && !noseImage.isEmpty) {
            // Subir imagen de nariz usando GcsService
            try {
                noseImageUrl = gcsService.uploadFile(noseImage, "noses")
                println("Nose image uploaded successfully: $noseImageUrl")
            } catch (e: Exception) {
                println("Failed to upload nose image: ${e.message}")
                // Continuar sin imagen de nariz
            }
        }

        val pet =
                Pet(
                        name = request.name,
                        breed = request.breed,
                        age = request.age,
                        sex = request.sex,
                        profileImageUrl = profileImageUrl,
                        noseImageUrl = noseImageUrl,
                        ownerId = request.ownerId,
                        userId = userId
                )

        val savedPet = petRepository.save(pet)

        // Registrar embedding en AI Service si hay imagen de nariz
        if (noseImage != null && !noseImage.isEmpty && noseImageUrl != null) {
            try {
                aiServiceClient.registerEmbedding(savedPet.id.toString(), noseImage)
                println("Embedding registered for pet ${savedPet.id}")
            } catch (e: Exception) {
                println("Failed to register embedding for pet ${savedPet.id}: ${e.message}")
            }
        }

        return savedPet.toResponse()
    }

    fun updatePet(id: UUID, request: UpdatePetRequest): PetResponse {
        val pet =
                petRepository.findById(id).orElseThrow {
                    RuntimeException("Pet not found with id: $id")
                }

        val updatedPet =
                pet.copy(
                        name = request.name,
                        breed = request.breed,
                        age = request.age,
                        sex = request.sex,
                        updatedAt = LocalDateTime.now()
                )

        val savedPet = petRepository.save(updatedPet)
        return savedPet.toResponse()
    }

    fun updatePetImages(
            id: UUID,
            profileImage: MultipartFile?,
            noseImage: MultipartFile?
    ): PetResponse {
        val pet =
                petRepository.findById(id).orElseThrow {
                    RuntimeException("Pet not found with id: $id")
                }

        var profileImageUrl = pet.profileImageUrl
        var noseImageUrl = pet.noseImageUrl

        // Subir nuevas imágenes usando GcsService
        if (profileImage != null && !profileImage.isEmpty) {
            try {
                profileImageUrl = gcsService.uploadFile(profileImage, "profiles")
                println("Profile image updated successfully: $profileImageUrl")
            } catch (e: Exception) {
                println("Failed to upload new profile image: ${e.message}")
                // Mantener la URL anterior si falla la subida
            }
        }

        if (noseImage != null && !noseImage.isEmpty) {
            try {
                noseImageUrl = gcsService.uploadFile(noseImage, "noses")
                println("Nose image updated successfully: $noseImageUrl")
            } catch (e: Exception) {
                println("Failed to upload new nose image: ${e.message}")
                // Mantener la URL anterior si falla la subida
            }
        }

        val updatedPet =
                pet.copy(
                        profileImageUrl = profileImageUrl,
                        noseImageUrl = noseImageUrl,
                        updatedAt = LocalDateTime.now()
                )

        val savedPet = petRepository.save(updatedPet)

        // Registrar embedding en AI Service si hay nueva imagen de nariz
        if (noseImage != null && !noseImage.isEmpty && noseImageUrl != null) {
            try {
                aiServiceClient.registerEmbedding(savedPet.id.toString(), noseImage)
                println("Embedding updated for pet ${savedPet.id}")
            } catch (e: Exception) {
                println("Failed to update embedding for pet ${savedPet.id}: ${e.message}")
            }
        }

        return savedPet.toResponse()
    }

    fun deletePet(id: UUID) {
        if (!petRepository.existsById(id)) {
            throw RuntimeException("Pet not found with id: $id")
        }
        petRepository.deleteById(id)
    }

    fun scanPet(image: MultipartFile): Map<String, Any> {
        try {
            println("=== PET SERVICE SCAN DEBUG ===")
            println("Image filename: ${image.originalFilename}")
            println("Image size: ${image.size} bytes")
            println("Image content type: ${image.contentType}")

            // Enviar imagen al AI Service para identificación
            val result = aiServiceClient.scanImage(image)

            println("AI Service result: $result")
            println("=== END PET SERVICE SCAN DEBUG ===")

            return result
        } catch (e: Exception) {
            println("=== PET SERVICE SCAN ERROR ===")
            println("Error scanning pet: ${e.message}")
            e.printStackTrace()
            println("=== END PET SERVICE SCAN ERROR ===")

            return mapOf(
                    "match" to false,
                    "confidence" to 0.0,
                    "error" to (e.message ?: "Unknown error")
            )
        }
    }

    fun visualComparison(image: MultipartFile): Map<String, Any> {
        try {
            println("=== PET SERVICE VISUAL COMPARISON DEBUG ===")
            println("Image filename: ${image.originalFilename}")
            println("Image size: ${image.size} bytes")
            println("Image content type: ${image.contentType}")

            // Enviar imagen al AI Service para comparación visual
            val result = aiServiceClient.visualComparison(image)

            println("AI Service visual comparison result: $result")
            println("=== END PET SERVICE VISUAL COMPARISON DEBUG ===")

            return result
        } catch (e: Exception) {
            println("=== PET SERVICE VISUAL COMPARISON ERROR ===")
            println("Error in visual comparison: ${e.message}")
            e.printStackTrace()
            println("=== END PET SERVICE VISUAL COMPARISON ERROR ===")

            return mapOf(
                    "error" to (e.message ?: "Unknown error"),
                    "uploaded_image_features" to emptyMap<String, Any>(),
                    "registered_pets_comparison" to emptyList<Map<String, Any>>(),
                    "top_matches" to emptyList<Map<String, Any>>(),
                    "analysis_summary" to emptyMap<String, Any>()
            )
        }
    }

    fun fixExistingPetUrls(): List<PetResponse> {
        println("=== FIXING EXISTING PET URLS ===")
        val allPets = petRepository.findAll()
        val fixedPets = mutableListOf<PetResponse>()

        for (pet in allPets) {
            try {
                println("Processing pet: ${pet.name} (ID: ${pet.id})")

                var needsUpdate = false
                var newProfileUrl = pet.profileImageUrl
                var newNoseUrl = pet.noseImageUrl

                // Verificar si la URL de perfil necesita arreglo
                val currentProfileUrl = pet.profileImageUrl
                if (currentProfileUrl == null ||
                                currentProfileUrl.contains("unsplash.com") ||
                                !isValidGcsUrl(currentProfileUrl)
                ) {

                    println("Fixing profile image for ${pet.name}")
                    val profileImageFile =
                            createMultipartFileFromResource("husky.jpg", "image/jpeg")
                    newProfileUrl = gcsService.uploadFile(profileImageFile, "profiles")
                    needsUpdate = true
                }

                // Verificar si la URL de nariz necesita arreglo
                val currentNoseUrl = pet.noseImageUrl
                if (currentNoseUrl == null ||
                                currentNoseUrl.contains("unsplash.com") ||
                                !isValidGcsUrl(currentNoseUrl)
                ) {

                    println("Fixing nose image for ${pet.name}")
                    val noseImageFile = createMultipartFileFromResource("husky.jpg", "image/jpeg")
                    newNoseUrl = gcsService.uploadFile(noseImageFile, "noses")
                    needsUpdate = true
                }

                // Actualizar la mascota si es necesario
                if (needsUpdate) {
                    val updatedPet =
                            pet.copy(
                                    profileImageUrl = newProfileUrl,
                                    noseImageUrl = newNoseUrl,
                                    updatedAt = LocalDateTime.now()
                            )
                    val savedPet = petRepository.save(updatedPet)
                    fixedPets.add(savedPet.toResponse())
                    println("✅ Fixed URLs for ${pet.name}")
                } else {
                    fixedPets.add(pet.toResponse())
                    println("✅ ${pet.name} already has valid URLs")
                }
            } catch (e: Exception) {
                println("❌ Error fixing URLs for ${pet.name}: ${e.message}")
                // Agregar la mascota sin cambios si hay error
                fixedPets.add(pet.toResponse())
            }
        }

        println("=== FINISHED FIXING PET URLS ===")
        return fixedPets
    }

    private fun isValidGcsUrl(url: String?): Boolean {
        if (url == null) return false
        return try {
            val response =
                    java.net.http.HttpClient.newHttpClient()
                            .send(
                                    java.net.http.HttpRequest.newBuilder()
                                            .uri(java.net.URI.create(url))
                                            .method(
                                                    "HEAD",
                                                    java.net.http.HttpRequest.BodyPublishers
                                                            .noBody()
                                            )
                                            .build(),
                                    java.net.http.HttpResponse.BodyHandlers.discarding()
                            )
            response.statusCode() == 200
        } catch (e: Exception) {
            false
        }
    }

    private fun createMultipartFileFromResource(
            filename: String,
            contentType: String
    ): MultipartFile {
        val resource = org.springframework.core.io.ClassPathResource(filename)
        val inputStream = resource.inputStream
        val bytes = inputStream.readAllBytes()
        inputStream.close()

        return object : MultipartFile {
            override fun getName(): String = filename
            override fun getOriginalFilename(): String? = filename
            override fun getContentType(): String? = contentType
            override fun isEmpty(): Boolean = bytes.isEmpty()
            override fun getSize(): Long = bytes.size.toLong()
            override fun getBytes(): ByteArray = bytes
            override fun getInputStream(): java.io.InputStream = java.io.ByteArrayInputStream(bytes)
            override fun transferTo(dest: java.io.File) {
                dest.writeBytes(bytes)
            }
        }
    }

    private fun Pet.toResponse(): PetResponse {
        return PetResponse(
                id = this.id,
                name = this.name,
                breed = this.breed,
                age = this.age,
                sex = this.sex.name,
                profileImageUrl = this.profileImageUrl,
                noseImageUrl = this.noseImageUrl,
                ownerId = this.ownerId,
                createdAt = this.createdAt,
                updatedAt = this.updatedAt
        )
    }
}
