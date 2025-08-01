// Controlador para gestión de mascotas
package com.petnow.pet.controller

import com.petnow.pet.dto.CreatePetRequest
import com.petnow.pet.dto.PetResponse
import com.petnow.pet.dto.UpdatePetRequest
import com.petnow.pet.service.PetService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import java.util.*
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import org.springframework.web.multipart.MultipartFile

@RestController
@RequestMapping("/pets")
@Tag(name = "Pets", description = "Pet management endpoints")
@CrossOrigin(origins = ["*"])
class PetController(private val petService: PetService) {

    @GetMapping("/test")
    @Operation(summary = "Test endpoint", description = "Simple test endpoint")
    fun test(): ResponseEntity<String> {
        return ResponseEntity.ok("Pet service is working!")
    }

    @GetMapping
    @Operation(summary = "Get all pets", description = "Retrieves a list of all pets")
    fun getAllPets(): ResponseEntity<List<PetResponse>> {
        val pets = petService.getAllPets()
        return ResponseEntity.ok(pets)
    }

    @GetMapping("/user/{userId}")
    @Operation(
            summary = "Get pets by user ID",
            description = "Retrieves a list of pets for a specific user"
    )
    fun getPetsByUserId(@PathVariable userId: Long): ResponseEntity<List<PetResponse>> {
        val pets = petService.getPetsByUserId(userId)
        return ResponseEntity.ok(pets)
    }

    @GetMapping("/all")
    @Operation(
            summary = "Get all pets (global access)",
            description = "Retrieves a list of all pets for scanner and global operations"
    )
    fun getAllPetsGlobal(): ResponseEntity<List<PetResponse>> {
        val pets = petService.getAllPets()
        return ResponseEntity.ok(pets)
    }

    @GetMapping("/owner/{ownerId}")
    @Operation(
            summary = "Get pets by owner ID",
            description = "Retrieves all pets for a specific owner"
    )
    fun getPetsByOwnerId(@PathVariable ownerId: UUID): ResponseEntity<List<PetResponse>> {
        val pets = petService.getPetsByOwnerId(ownerId)
        return ResponseEntity.ok(pets)
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get pet by ID", description = "Retrieves a specific pet by their ID")
    fun getPetById(@PathVariable id: UUID): ResponseEntity<PetResponse> {
        val pet = petService.getPetById(id)
        return ResponseEntity.ok(pet)
    }

    @PostMapping
    @Operation(summary = "Create pet", description = "Creates a new pet")
    fun createPet(@Valid @RequestBody request: CreatePetRequest): ResponseEntity<PetResponse> {
        // Usar userId por defecto ya que eliminamos JWT
        val userId = 1L
        val pet = petService.createPet(request, userId)
        return ResponseEntity.status(HttpStatus.CREATED).body(pet)
    }

    @PostMapping(value = ["/with-images"], consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    @Operation(
            summary = "Create pet with images",
            description = "Creates a new pet with profile and nose images"
    )
    fun createPetWithImages(
            @RequestParam("name") name: String,
            @RequestParam("breed") breed: String,
            @RequestParam("age") age: Int,
            @RequestParam("sex") sex: String,
            @RequestParam("ownerId") ownerId: String,
            @RequestParam("userId", required = false) userId: Long?,
            @RequestParam("profileImage", required = false) profileImage: MultipartFile?,
            @RequestParam("noseImage", required = false) noseImage: MultipartFile?
    ): ResponseEntity<PetResponse> {
        val request =
                CreatePetRequest(
                        name = name,
                        breed = breed,
                        age = age,
                        sex = com.petnow.pet.entity.PetSex.valueOf(sex.uppercase()),
                        ownerId = UUID.fromString(ownerId)
                )

        // Usar userId del request o por defecto
        val finalUserId = userId ?: 1L
        val pet = petService.createPetWithImages(request, profileImage, noseImage, finalUserId)
        return ResponseEntity.status(HttpStatus.CREATED).body(pet)
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update pet", description = "Updates an existing pet")
    fun updatePet(
            @PathVariable id: UUID,
            @Valid @RequestBody request: UpdatePetRequest
    ): ResponseEntity<PetResponse> {
        val pet = petService.updatePet(id, request)
        return ResponseEntity.ok(pet)
    }

    @PutMapping("/{id}/images", consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    @Operation(
            summary = "Update pet images",
            description = "Updates profile and nose images for a pet"
    )
    fun updatePetImages(
            @PathVariable id: UUID,
            @RequestParam("profileImage", required = false) profileImage: MultipartFile?,
            @RequestParam("noseImage", required = false) noseImage: MultipartFile?
    ): ResponseEntity<PetResponse> {
        val pet = petService.updatePetImages(id, profileImage, noseImage)
        return ResponseEntity.ok(pet)
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete pet", description = "Deletes a pet")
    fun deletePet(@PathVariable id: UUID): ResponseEntity<Void> {
        petService.deletePet(id)
        return ResponseEntity.noContent().build()
    }

    @PostMapping("/scan", consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    @Operation(
            summary = "Scan pet nose",
            description = "Scans a nose image to identify a pet using AI"
    )
    fun scanPet(@RequestParam("image") image: MultipartFile): ResponseEntity<Map<String, Any>> {
        val result = petService.scanPet(image)
        return ResponseEntity.ok(result)
    }

    @PostMapping("/visual-comparison", consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    @Operation(
            summary = "Visual comparison of nose prints",
            description =
                    "Performs detailed visual comparison of nose prints with all registered pets"
    )
    fun visualComparison(
            @RequestParam("image") image: MultipartFile
    ): ResponseEntity<Map<String, Any>> {
        val result = petService.visualComparison(image)
        return ResponseEntity.ok(result)
    }

    @PostMapping("/fix-urls")
    @Operation(
            summary = "Fix existing pet URLs",
            description = "Fixes image URLs for all existing pets by uploading images to GCS"
    )
    fun fixExistingPetUrls(): ResponseEntity<List<PetResponse>> {
        val fixedPets = petService.fixExistingPetUrls()
        return ResponseEntity.ok(fixedPets)
    }

    @GetMapping("/images/{filename:.+}")
    @Operation(summary = "Get image", description = "Serves local images stored by the pet service")
    fun getImage(
            @PathVariable filename: String
    ): ResponseEntity<org.springframework.core.io.Resource> {
        val imagePath = "/tmp/pet-images/$filename"
        val resource = org.springframework.core.io.FileSystemResource(imagePath)
        return if (resource.exists()) {
            ResponseEntity.ok().header("Content-Type", "image/jpeg").body(resource)
        } else {
            ResponseEntity.notFound().build()
        }
    }
}
