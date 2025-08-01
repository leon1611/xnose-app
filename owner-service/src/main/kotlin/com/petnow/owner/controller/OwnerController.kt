package com.petnow.owner.controller

import com.petnow.owner.dto.CreateOwnerRequest
import com.petnow.owner.dto.OwnerResponse
import com.petnow.owner.dto.UpdateOwnerRequest
import com.petnow.owner.service.OwnerService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import java.util.*
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/owners")
@Tag(name = "Owners", description = "Owner management endpoints")
@CrossOrigin(origins = ["*"])
class OwnerController(private val ownerService: OwnerService) {

    @GetMapping
    @Operation(summary = "Get all owners", description = "Retrieves a list of all owners")
    fun getAllOwners(): ResponseEntity<List<OwnerResponse>> {
        val owners = ownerService.getAllOwners()
        return ResponseEntity.ok(owners)
    }

    @GetMapping("/user/{userId}")
    @Operation(
            summary = "Get owners by user ID",
            description = "Retrieves a list of owners for a specific user"
    )
    fun getOwnersByUserId(@PathVariable userId: Long): ResponseEntity<List<OwnerResponse>> {
        val owners = ownerService.getOwnersByUserId(userId)
        return ResponseEntity.ok(owners)
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get owner by ID", description = "Retrieves a specific owner by their ID")
    fun getOwnerById(@PathVariable id: UUID): ResponseEntity<OwnerResponse> {
        val owner = ownerService.getOwnerById(id)
        return ResponseEntity.ok(owner)
    }

    @PostMapping
    @Operation(summary = "Create owner", description = "Creates a new owner")
    fun createOwner(
            @Valid @RequestBody request: CreateOwnerRequest
    ): ResponseEntity<OwnerResponse> {
        val owner = ownerService.createOwner(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(owner)
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update owner", description = "Updates an existing owner")
    fun updateOwner(
            @PathVariable id: UUID,
            @Valid @RequestBody request: UpdateOwnerRequest
    ): ResponseEntity<OwnerResponse> {
        val owner = ownerService.updateOwner(id, request)
        return ResponseEntity.ok(owner)
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete owner", description = "Deletes an owner")
    fun deleteOwner(@PathVariable id: UUID): ResponseEntity<Void> {
        ownerService.deleteOwner(id)
        return ResponseEntity.noContent().build()
    }
}
