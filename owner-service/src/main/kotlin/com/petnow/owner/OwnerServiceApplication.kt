package com.petnow.owner

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class OwnerServiceApplication

fun main(args: Array<String>) {
    runApplication<OwnerServiceApplication>(*args)
} 