package com.petnow.pet.repository

import com.petnow.pet.entity.Pet
import java.util.*
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface PetRepository : JpaRepository<Pet, UUID> {
    fun findByOwnerId(ownerId: UUID): List<Pet>
    fun findByBreed(breed: String): List<Pet>
    fun findByUserId(userId: Long): List<Pet> // Nuevo método para filtrar por usuario
}
