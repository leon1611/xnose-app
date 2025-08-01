package com.petnow.owner.dto

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Pattern
import java.time.LocalDateTime
import java.util.*

data class CreateOwnerRequest(
        @field:NotBlank(message = "Name is required")
        @field:Pattern(
                regexp = "^[a-zA-Z\\s]+$",
                message = "Name must contain only letters and spaces"
        )
        val name: String,
        @field:NotBlank(message = "Email is required")
        @field:Email(message = "Email must be valid")
        val email: String,
        @field:NotBlank(message = "Phone is required")
        @field:Pattern(
                regexp = "^[+]?[0-9\\s\\-()]+$",
                message = "Phone must contain only numbers, spaces, hyphens, and parentheses"
        )
        val phone: String,
        @field:NotBlank(message = "Address is required") val address: String,
        val userId: Long? = null // Campo opcional para el userId
)

data class UpdateOwnerRequest(
        @field:NotBlank(message = "Name is required")
        @field:Pattern(
                regexp = "^[a-zA-Z\\s]+$",
                message = "Name must contain only letters and spaces"
        )
        val name: String,
        @field:NotBlank(message = "Phone is required")
        @field:Pattern(
                regexp = "^[+]?[0-9\\s\\-()]+$",
                message = "Phone must contain only numbers, spaces, hyphens, and parentheses"
        )
        val phone: String,
        @field:NotBlank(message = "Address is required") val address: String
)

data class OwnerResponse(
        val id: UUID,
        val name: String,
        val email: String,
        val phone: String,
        val address: String,
        val createdAt: LocalDateTime,
        val updatedAt: LocalDateTime
)
