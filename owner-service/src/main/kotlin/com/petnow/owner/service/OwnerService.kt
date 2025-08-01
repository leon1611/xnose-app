package com.petnow.owner.service

import com.petnow.owner.dto.CreateOwnerRequest
import com.petnow.owner.dto.OwnerResponse
import com.petnow.owner.dto.UpdateOwnerRequest
import com.petnow.owner.entity.Owner
import com.petnow.owner.repository.OwnerRepository
import java.time.LocalDateTime
import java.util.*
import org.springframework.stereotype.Service

@Service
class OwnerService(private val ownerRepository: OwnerRepository) {

    fun getAllOwners(): List<OwnerResponse> {
        return ownerRepository.findAll().map { it.toResponse() }
    }

    fun getOwnersByUserId(userId: Long): List<OwnerResponse> {
        return ownerRepository.findByUserId(userId).map { it.toResponse() }
    }

    fun getOwnerById(id: UUID): OwnerResponse {
        val owner =
                ownerRepository.findById(id).orElseThrow {
                    RuntimeException("Owner not found with id: $id")
                }
        return owner.toResponse()
    }

    fun createOwner(request: CreateOwnerRequest): OwnerResponse {
        // Verificar si el email ya existe
        val existingOwner = ownerRepository.findByEmail(request.email)
        if (existingOwner.isPresent) {
            throw RuntimeException("Owner with email ${request.email} already exists")
        }

        val owner =
                Owner(
                        name = request.name,
                        email = request.email,
                        phone = request.phone,
                        address = request.address,
                        userId = request.userId ?: 1L // Usar userId del request o por defecto
                )

        val savedOwner = ownerRepository.save(owner)
        return savedOwner.toResponse()
    }

    fun updateOwner(id: UUID, request: UpdateOwnerRequest): OwnerResponse {
        val existingOwner =
                ownerRepository.findById(id).orElseThrow {
                    RuntimeException("Owner not found with id: $id")
                }

        val updatedOwner =
                existingOwner.copy(
                        name = request.name,
                        phone = request.phone,
                        address = request.address,
                        updatedAt = LocalDateTime.now()
                )

        val savedOwner = ownerRepository.save(updatedOwner)
        return savedOwner.toResponse()
    }

    fun deleteOwner(id: UUID) {
        if (!ownerRepository.existsById(id)) {
            throw RuntimeException("Owner not found with id: $id")
        }
        ownerRepository.deleteById(id)
    }

    private fun Owner.toResponse(): OwnerResponse {
        return OwnerResponse(
                id = this.id!!,
                name = this.name,
                email = this.email,
                phone = this.phone,
                address = this.address,
                createdAt = this.createdAt,
                updatedAt = this.updatedAt
        )
    }
}
