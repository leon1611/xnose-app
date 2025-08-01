package com.petnow.alert.entity

import jakarta.persistence.*
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "alerts")
data class Alert(
        @Id @GeneratedValue(strategy = GenerationType.UUID) val id: UUID? = null,
        @field:NotNull(message = "Pet ID is required") @Column(nullable = false) val petId: UUID,
        @Enumerated(EnumType.STRING) @Column(nullable = false) val type: AlertType,
        @field:NotBlank(message = "Location is required")
        @Column(nullable = false)
        val location: String,
        @field:NotBlank(message = "Description is required")
        @Column(nullable = false, columnDefinition = "TEXT")
        val description: String,
        @Column(nullable = false) val createdAt: LocalDateTime = LocalDateTime.now(),
        @Column(nullable = false) val updatedAt: LocalDateTime = LocalDateTime.now(),
        @Column(nullable = false) val active: Boolean = true,
        @Column(nullable = false) val userId: Long = 1 // Campo para asociar con usuario
) {
        constructor() :
                this(
                        null,
                        UUID.randomUUID(),
                        AlertType.LOST,
                        "",
                        "",
                        LocalDateTime.now(),
                        LocalDateTime.now(),
                        true,
                        1
                )
}

enum class AlertType {
        LOST,
        FOUND
}
