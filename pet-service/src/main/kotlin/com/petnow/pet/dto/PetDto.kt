package com.petnow.pet.dto

import com.petnow.pet.entity.PetSex
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Positive
import java.time.LocalDateTime
import java.util.*

data class CreatePetRequest(
        @field:NotBlank(message = "Name is required") val name: String,
        @field:NotBlank(message = "Breed is required") val breed: String,
        @field:NotNull(message = "Age is required")
        @field:Positive(message = "Age must be positive")
        val age: Int,
        @field:NotNull(message = "Sex is required") val sex: PetSex,
        @field:NotNull(message = "Owner ID is required") val ownerId: UUID
)

data class UpdatePetRequest(
        @field:NotBlank(message = "Name is required") val name: String,
        @field:NotBlank(message = "Breed is required") val breed: String,
        @field:NotNull(message = "Age is required")
        @field:Positive(message = "Age must be positive")
        val age: Int,
        @field:NotNull(message = "Sex is required") val sex: PetSex
)

data class PetResponse(
        val id: UUID,
        val name: String,
        val breed: String,
        val age: Int,
        val sex: String,
        val profileImageUrl: String?,
        val noseImageUrl: String?,
        val ownerId: UUID,
        val createdAt: LocalDateTime,
        val updatedAt: LocalDateTime
)
