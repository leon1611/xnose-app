package com.petnow.alert.dto

import com.petnow.alert.entity.AlertType
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import java.time.LocalDateTime
import java.util.*

data class CreateAlertRequest(
        @field:NotNull(message = "Pet ID is required") val petId: UUID,
        @field:NotNull(message = "Alert type is required") val type: AlertType,
        @field:NotBlank(message = "Location is required") val location: String,
        @field:NotBlank(message = "Description is required") val description: String
)

data class UpdateAlertRequest(
        @field:NotBlank(message = "Location is required") val location: String,
        @field:NotBlank(message = "Description is required") val description: String,
        val active: Boolean = true
)

data class AlertResponse(
        val id: UUID,
        val petId: UUID,
        val type: AlertType,
        val location: String,
        val description: String,
        val createdAt: LocalDateTime,
        val updatedAt: LocalDateTime,
        val active: Boolean,
        val petProfileImageUrl: String? = null,
        val petName: String? = null
)
