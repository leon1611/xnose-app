package com.petnow.auth.dto

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

// Registro

data class RegisterRequest(
    @field:NotBlank(message = "Username is required")
    @field:Size(min = 3, max = 50)
    val username: String,
    @field:NotBlank(message = "Email is required")
    @field:Email(message = "Invalid email")
    val email: String,
    @field:NotBlank(message = "Password is required")
    @field:Size(min = 6)
    val password: String,
    val role: String? = null
)

data class LoginRequest(
    @field:NotBlank(message = "Username is required")
    val username: String,
    @field:NotBlank(message = "Password is required")
    val password: String
)

data class UserResponse(
    val id: Long,
    val username: String,
    val email: String,
    val role: String,
    val enabled: Boolean
) 