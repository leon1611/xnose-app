package com.petnow.alert.service

import com.petnow.alert.dto.AlertResponse
import com.petnow.alert.dto.CreateAlertRequest
import com.petnow.alert.dto.UpdateAlertRequest
import com.petnow.alert.entity.Alert
import com.petnow.alert.entity.AlertType
import com.petnow.alert.repository.AlertRepository
import java.time.LocalDateTime
import java.util.*
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate

@Service
class AlertService(private val alertRepository: AlertRepository) {
    private val petServiceUrl =
            "http://192.168.0.104:8083/pets" // Llamar directamente al Pet Service
    private val restTemplate = RestTemplate()

    fun getAllAlerts(): List<AlertResponse> {
        return alertRepository.findAll().map { it.toResponse() }
    }

    fun getAlertsByUserId(userId: Long): List<AlertResponse> {
        return alertRepository.findByUserId(userId).map { it.toResponse() }
    }

    fun getAlertById(id: UUID): AlertResponse {
        val alert =
                alertRepository.findById(id).orElseThrow {
                    RuntimeException("Alert not found with id: $id")
                }
        return alert.toResponse()
    }

    fun getAlertsByPetId(petId: UUID): List<AlertResponse> {
        return alertRepository.findByPetId(petId).map { it.toResponse() }
    }

    fun getAlertsByType(type: AlertType): List<AlertResponse> {
        return alertRepository.findByType(type).map { it.toResponse() }
    }

    fun getActiveAlerts(): List<AlertResponse> {
        return alertRepository.findByActive(true).map { it.toResponse() }
    }

    fun getActiveAlertsByPetId(petId: UUID): List<AlertResponse> {
        return alertRepository.findByPetIdAndActive(petId, true).map { it.toResponse() }
    }

    fun createAlert(request: CreateAlertRequest): AlertResponse {
        val alert =
                Alert(
                        petId = request.petId,
                        type = request.type,
                        location = request.location,
                        description = request.description
                )

        val savedAlert = alertRepository.save(alert)
        return savedAlert.toResponse()
    }

    fun updateAlert(id: UUID, request: UpdateAlertRequest): AlertResponse {
        val alert =
                alertRepository.findById(id).orElseThrow {
                    RuntimeException("Alert not found with id: $id")
                }

        val updatedAlert =
                alert.copy(
                        location = request.location,
                        description = request.description,
                        active = request.active,
                        updatedAt = LocalDateTime.now()
                )

        val savedAlert = alertRepository.save(updatedAlert)
        return savedAlert.toResponse()
    }

    fun deactivateAlert(id: UUID): AlertResponse {
        val alert =
                alertRepository.findById(id).orElseThrow {
                    RuntimeException("Alert not found with id: $id")
                }

        val updatedAlert = alert.copy(active = false, updatedAt = LocalDateTime.now())

        val savedAlert = alertRepository.save(updatedAlert)
        return savedAlert.toResponse()
    }

    fun deleteAlert(id: UUID) {
        if (!alertRepository.existsById(id)) {
            throw RuntimeException("Alert not found with id: $id")
        }
        alertRepository.deleteById(id)
    }

    fun cleanupOrphanedAlerts(): Map<String, Any> {
        val allAlerts = alertRepository.findAll()
        val orphanedAlerts = mutableListOf<Alert>()
        val validAlerts = mutableListOf<Alert>()

        println("=== CLEANUP ORPHANED ALERTS ===")
        println("Total alerts: ${allAlerts.size}")

        for (alert in allAlerts) {
            try {
                val petResponse =
                        restTemplate.getForObject("$petServiceUrl/${alert.petId}", Map::class.java)
                if (petResponse != null) {
                    validAlerts.add(alert)
                    println("✅ Alert ${alert.id} -> Pet ${alert.petId} exists")
                } else {
                    orphanedAlerts.add(alert)
                    println("❌ Alert ${alert.id} -> Pet ${alert.petId} NOT FOUND")
                }
            } catch (e: Exception) {
                orphanedAlerts.add(alert)
                println("❌ Alert ${alert.id} -> Pet ${alert.petId} ERROR: ${e.message}")
            }
        }

        // Eliminar alertas huérfanas
        for (orphanedAlert in orphanedAlerts) {
            alertRepository.deleteById(orphanedAlert.id!!)
            println("🗑️ Deleted orphaned alert: ${orphanedAlert.id}")
        }

        println("Cleanup completed:")
        println("  - Valid alerts: ${validAlerts.size}")
        println("  - Orphaned alerts removed: ${orphanedAlerts.size}")
        println("=== END CLEANUP ===")

        return mapOf(
                "totalAlerts" to allAlerts.size,
                "validAlerts" to validAlerts.size,
                "orphanedAlertsRemoved" to orphanedAlerts.size
        )
    }

    fun getValidAlerts(): List<AlertResponse> {
        val allAlerts = alertRepository.findAll()
        val validAlerts = mutableListOf<AlertResponse>()

        for (alert in allAlerts) {
            try {
                val petResponse =
                        restTemplate.getForObject("$petServiceUrl/${alert.petId}", Map::class.java)
                if (petResponse != null) {
                    validAlerts.add(alert.toResponse())
                }
            } catch (e: Exception) {
                // Ignorar alertas con mascotas inexistentes
                println("Skipping orphaned alert ${alert.id} -> Pet ${alert.petId}: ${e.message}")
            }
        }

        return validAlerts
    }

    private fun Alert.toResponse(): AlertResponse {
        // Consultar pet-service para obtener la URL de la foto y el nombre
        var petProfileImageUrl: String? = null
        var petName: String? = null
        try {
            println("=== ALERT SERVICE DEBUG ===")
            println("Consultando mascota: $petId")
            println("URL: $petServiceUrl/$petId")

            val petResponse = restTemplate.getForObject("$petServiceUrl/$petId", Map::class.java)

            if (petResponse != null) {
                petProfileImageUrl = petResponse["profileImageUrl"] as? String
                petName = petResponse["name"] as? String

                println("Respuesta exitosa:")
                println("  - Nombre: $petName")
                println("  - Foto: $petProfileImageUrl")
            } else {
                println("Respuesta nula del Pet Service")
            }
            println("=== END ALERT SERVICE DEBUG ===")
        } catch (e: Exception) {
            println("=== ALERT SERVICE ERROR ===")
            println("Error consultando mascota $petId: ${e.message}")
            println("Tipo de error: ${e.javaClass.simpleName}")
            e.printStackTrace()
            println("=== END ALERT SERVICE ERROR ===")

            petProfileImageUrl = null
            petName = null
        }

        return AlertResponse(
                id = this.id!!,
                petId = this.petId,
                type = this.type,
                location = this.location,
                description = this.description,
                createdAt = this.createdAt,
                updatedAt = this.updatedAt,
                active = this.active,
                petProfileImageUrl = petProfileImageUrl,
                petName = petName
        )
    }
}
