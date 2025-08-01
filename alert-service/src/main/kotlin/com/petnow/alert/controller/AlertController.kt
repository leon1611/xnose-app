package com.petnow.alert.controller

import com.petnow.alert.dto.AlertResponse
import com.petnow.alert.dto.CreateAlertRequest
import com.petnow.alert.dto.UpdateAlertRequest
import com.petnow.alert.entity.AlertType
import com.petnow.alert.service.AlertService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import java.util.*
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/alerts")
@Tag(name = "Alerts", description = "Alert management endpoints")
@CrossOrigin(origins = ["*"])
class AlertController(private val alertService: AlertService) {

    @GetMapping
    @Operation(
            summary = "Get all alerts",
            description = "Retrieves a list of all alerts (shared globally between all users)"
    )
    fun getAllAlerts(): ResponseEntity<List<AlertResponse>> {
        val alerts = alertService.getAllAlerts()
        return ResponseEntity.ok(alerts)
    }

    @GetMapping("/user/{userId}")
    @Operation(
            summary = "Get alerts by user ID",
            description = "Retrieves a list of alerts for a specific user"
    )
    fun getAlertsByUserId(@PathVariable userId: Long): ResponseEntity<List<AlertResponse>> {
        val alerts = alertService.getAlertsByUserId(userId)
        return ResponseEntity.ok(alerts)
    }

    @GetMapping("/active")
    @Operation(
            summary = "Get active alerts",
            description = "Retrieves a list of all active alerts (shared globally)"
    )
    fun getActiveAlerts(): ResponseEntity<List<AlertResponse>> {
        val alerts = alertService.getActiveAlerts()
        return ResponseEntity.ok(alerts)
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get alert by ID", description = "Retrieves a specific alert by its ID")
    fun getAlertById(@PathVariable id: UUID): ResponseEntity<AlertResponse> {
        val alert = alertService.getAlertById(id)
        return ResponseEntity.ok(alert)
    }

    @GetMapping("/pet/{petId}")
    @Operation(
            summary = "Get alerts by pet ID",
            description = "Retrieves all alerts for a specific pet"
    )
    fun getAlertsByPetId(@PathVariable petId: UUID): ResponseEntity<List<AlertResponse>> {
        val alerts = alertService.getAlertsByPetId(petId)
        return ResponseEntity.ok(alerts)
    }

    @GetMapping("/pet/{petId}/active")
    @Operation(
            summary = "Get active alerts by pet ID",
            description = "Retrieves all active alerts for a specific pet"
    )
    fun getActiveAlertsByPetId(@PathVariable petId: UUID): ResponseEntity<List<AlertResponse>> {
        val alerts = alertService.getActiveAlertsByPetId(petId)
        return ResponseEntity.ok(alerts)
    }

    @GetMapping("/type/{type}")
    @Operation(
            summary = "Get alerts by type",
            description = "Retrieves all alerts of a specific type (LOST/FOUND)"
    )
    fun getAlertsByType(@PathVariable type: String): ResponseEntity<List<AlertResponse>> {
        val alertType = AlertType.valueOf(type.uppercase())
        val alerts = alertService.getAlertsByType(alertType)
        return ResponseEntity.ok(alerts)
    }

    @PostMapping
    @Operation(summary = "Create alert", description = "Creates a new alert (shared globally)")
    fun createAlert(
            @Valid @RequestBody request: CreateAlertRequest
    ): ResponseEntity<AlertResponse> {
        val alert = alertService.createAlert(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(alert)
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update alert", description = "Updates an existing alert")
    fun updateAlert(
            @PathVariable id: UUID,
            @Valid @RequestBody request: UpdateAlertRequest
    ): ResponseEntity<AlertResponse> {
        val alert = alertService.updateAlert(id, request)
        return ResponseEntity.ok(alert)
    }

    @PutMapping("/{id}/deactivate")
    @Operation(summary = "Deactivate alert", description = "Deactivates an alert")
    fun deactivateAlert(@PathVariable id: UUID): ResponseEntity<AlertResponse> {
        val alert = alertService.deactivateAlert(id)
        return ResponseEntity.ok(alert)
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete alert", description = "Deletes an alert")
    fun deleteAlert(@PathVariable id: UUID): ResponseEntity<Void> {
        alertService.deleteAlert(id)
        return ResponseEntity.noContent().build()
    }

    @PostMapping("/cleanup-orphaned")
    @Operation(
            summary = "Clean up orphaned alerts",
            description = "Removes alerts that reference non-existent pets"
    )
    fun cleanupOrphanedAlerts(): ResponseEntity<Map<String, Any>> {
        val result = alertService.cleanupOrphanedAlerts()
        return ResponseEntity.ok(result)
    }

    @GetMapping("/valid-alerts")
    @Operation(
            summary = "Get valid alerts only",
            description = "Retrieves only alerts that reference existing pets"
    )
    fun getValidAlerts(): ResponseEntity<List<AlertResponse>> {
        val alerts = alertService.getValidAlerts()
        return ResponseEntity.ok(alerts)
    }
}
