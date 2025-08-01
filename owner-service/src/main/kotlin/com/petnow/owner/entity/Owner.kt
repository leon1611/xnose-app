package com.petnow.owner.entity

import jakarta.persistence.*
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Pattern
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "owners")
data class Owner(
        @Id val id: UUID = UUID.randomUUID(),
        @field:NotBlank(message = "Name is required")
        @field:Pattern(
                regexp = "^[a-zA-Z\\s]+$",
                message = "Name must contain only letters and spaces"
        )
        @Column(nullable = false)
        var name: String,
        @field:NotBlank(message = "Email is required")
        @field:Email(message = "Email must be valid")
        @Column(unique = true, nullable = false)
        var email: String,
        @field:NotBlank(message = "Phone is required")
        @field:Pattern(
                regexp = "^[+]?[0-9\\s\\-()]+$",
                message = "Phone must contain only numbers, spaces, hyphens, and parentheses"
        )
        @Column(nullable = false)
        var phone: String,
        @field:NotBlank(message = "Address is required")
        @Column(nullable = false)
        var address: String,
        @Column(nullable = false) var userId: Long, // Campo para asociar con usuario
        @Column(nullable = false) var createdAt: LocalDateTime = LocalDateTime.now(),
        @Column(nullable = false) var updatedAt: LocalDateTime = LocalDateTime.now()
) {
        constructor() :
                this(UUID.randomUUID(), "", "", "", "", 1, LocalDateTime.now(), LocalDateTime.now())
}
