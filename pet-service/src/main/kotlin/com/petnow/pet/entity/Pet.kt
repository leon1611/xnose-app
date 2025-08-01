package com.petnow.pet.entity

import jakarta.persistence.*
import java.time.LocalDateTime
import java.util.*

@Entity
@Table(name = "pets")
data class Pet(
        @Id val id: UUID = UUID.randomUUID(),
        var name: String,
        var breed: String,
        var age: Int,
        var sex: PetSex,
        var profileImageUrl: String? = null,
        var noseImageUrl: String? = null,
        var ownerId: UUID,
        var userId: Long, // Campo para asociar con usuario
        var createdAt: LocalDateTime = LocalDateTime.now(),
        var updatedAt: LocalDateTime = LocalDateTime.now()
) {
        constructor() :
                this(
                        UUID.randomUUID(),
                        "",
                        "",
                        0,
                        PetSex.MALE,
                        null,
                        null,
                        UUID.randomUUID(),
                        1, // userId por defecto
                        LocalDateTime.now(),
                        LocalDateTime.now()
                )
}

enum class PetSex {
        MALE,
        FEMALE
}
