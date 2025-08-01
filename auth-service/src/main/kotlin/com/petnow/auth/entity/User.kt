package com.petnow.auth.entity

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "users")
data class User(
        @Id @GeneratedValue(strategy = GenerationType.IDENTITY) val id: Long? = null,
        @Column(unique = true, nullable = false) val username: String,
        @Column(unique = true, nullable = false) val email: String,
        @Column(nullable = false) val passwordHash: String,
        @Enumerated(EnumType.STRING) @Column(nullable = false) val role: UserRole = UserRole.USER,
        @Column(nullable = false) val enabled: Boolean = true,
        @Column(nullable = false) val createdAt: LocalDateTime = LocalDateTime.now()
) {
    // Constructor sin argumentos para JPA
    constructor() :
            this(
                    id = null,
                    username = "",
                    email = "",
                    passwordHash = "",
                    role = UserRole.USER,
                    enabled = true,
                    createdAt = LocalDateTime.now()
            )
}

enum class UserRole {
    USER,
    ADMIN
}
