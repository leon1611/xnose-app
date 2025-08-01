package com.petnow.owner.repository

import com.petnow.owner.entity.Owner
import java.util.*
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface OwnerRepository : JpaRepository<Owner, UUID> {
    fun findByEmail(email: String): Optional<Owner>
    fun existsByEmail(email: String): Boolean
    fun findByUserId(userId: Long): List<Owner> // Nuevo método para filtrar por usuario
}
