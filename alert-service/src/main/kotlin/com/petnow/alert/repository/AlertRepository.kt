package com.petnow.alert.repository

import com.petnow.alert.entity.Alert
import com.petnow.alert.entity.AlertType
import java.util.*
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface AlertRepository : JpaRepository<Alert, UUID> {
    fun findByPetId(petId: UUID): List<Alert>
    fun findByType(type: AlertType): List<Alert>
    fun findByActive(active: Boolean): List<Alert>
    fun findByPetIdAndActive(petId: UUID, active: Boolean): List<Alert>
    fun findByUserId(userId: Long): List<Alert> // Nuevo método para filtrar por usuario
}
