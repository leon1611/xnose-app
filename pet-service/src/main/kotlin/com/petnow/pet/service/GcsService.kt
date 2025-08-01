package com.petnow.pet.service

import com.google.auth.oauth2.GoogleCredentials
import com.google.cloud.storage.BlobInfo
import com.google.cloud.storage.Storage
import com.google.cloud.storage.StorageOptions
import java.io.FileInputStream
import java.util.*
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.web.multipart.MultipartFile

@Service
class GcsService {
        @Value("\${gcs.bucket-name:petnow-dogs-images-app-biometrico-db}")
        private lateinit var bucketName: String

        @Value("\${gcs.enabled:true}") private var gcsEnabled: Boolean = true

        @Value("\${gcs.project-id:app-biometrico-db}") private lateinit var projectId: String

        private val storage: Storage by lazy {
                try {
                        // Intentar usar credenciales del archivo JSON
                        val credentialsFile = FileInputStream("app-biometrico-db-5e6c55538b1b.json")
                        val credentials = GoogleCredentials.fromStream(credentialsFile)

                        StorageOptions.newBuilder()
                                .setCredentials(credentials)
                                .setProjectId(projectId)
                                .build()
                                .service
                } catch (e: Exception) {
                        println("Error loading GCS credentials: ${e.message}")
                        // Fallback a credenciales por defecto
                        StorageOptions.getDefaultInstance().service
                }
        }

        fun uploadFile(file: MultipartFile, folder: String): String {
                if (!gcsEnabled) {
                        // Si GCS está deshabilitado, devolver URL mock
                        val mockFileName =
                                folder +
                                        "/" +
                                        UUID.randomUUID().toString() +
                                        "_" +
                                        file.originalFilename
                        return "https://storage.googleapis.com/$bucketName/$mockFileName"
                }

                try {
                        val fileName =
                                folder +
                                        "/" +
                                        UUID.randomUUID().toString() +
                                        "_" +
                                        file.originalFilename
                        val blobInfo =
                                BlobInfo.newBuilder(bucketName, fileName)
                                        .setContentType(file.contentType)
                                        .build()

                        println("Uploading to GCS: bucket=$bucketName, file=$fileName")
                        val blob = storage.create(blobInfo, file.bytes)
                        println("Successfully uploaded to GCS: ${blob.name}")

                        // Configurar como público
                        blob.createAcl(
                                com.google.cloud.storage.Acl.of(
                                        com.google.cloud.storage.Acl.User.ofAllUsers(),
                                        com.google.cloud.storage.Acl.Role.READER
                                )
                        )

                        // URL pública
                        val publicUrl = "https://storage.googleapis.com/$bucketName/$fileName"
                        println("Public URL: $publicUrl")
                        return publicUrl
                } catch (e: Exception) {
                        println("Error uploading to GCS: ${e.message}")
                        e.printStackTrace()
                        throw RuntimeException("Failed to upload file to GCS: ${e.message}", e)
                }
        }
}
