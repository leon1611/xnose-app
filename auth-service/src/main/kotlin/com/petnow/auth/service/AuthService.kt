package com.petnow.auth.service

import com.petnow.auth.dto.LoginRequest
import com.petnow.auth.dto.RegisterRequest
import com.petnow.auth.dto.UserResponse
import com.petnow.auth.entity.User
import com.petnow.auth.entity.UserRole
import com.petnow.auth.repository.UserRepository
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
open class AuthService(
        private val userRepository: UserRepository,
        private val passwordEncoder: PasswordEncoder
) {
    @Transactional
    open fun register(request: RegisterRequest): UserResponse {
        if (userRepository.existsByUsername(request.username)) {
            throw RuntimeException("Username already exists")
        }
        if (userRepository.existsByEmail(request.email)) {
            throw RuntimeException("Email already exists")
        }
        val user =
                User(
                        username = request.username,
                        email = request.email,
                        passwordHash = passwordEncoder.encode(request.password),
                        role = request.role?.let { UserRole.valueOf(it) } ?: UserRole.USER
                )
        val saved = userRepository.save(user)
        return UserResponse(
                id = saved.id!!,
                username = saved.username,
                email = saved.email,
                role = saved.role.name,
                enabled = saved.enabled
        )
    }

    open fun login(request: LoginRequest): UserResponse {
        val user =
                userRepository.findByUsername(request.username).orElseThrow {
                    RuntimeException("Invalid credentials")
                }
        if (!passwordEncoder.matches(request.password, user.passwordHash)) {
            throw RuntimeException("Invalid credentials")
        }
        return UserResponse(
                id = user.id!!,
                username = user.username,
                email = user.email,
                role = user.role.name,
                enabled = user.enabled
        )
    }
}
