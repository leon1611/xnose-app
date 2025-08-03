# Multi-stage build para Pet Service
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de Maven
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .

# Descargar dependencias (caché layer)
RUN mvn dependency:go-offline -B

# Copiar código fuente
COPY src ./src

# Compilar la aplicación
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

# Instalar dependencias del sistema
RUN apk add --no-cache curl

# Crear usuario no-root
RUN addgroup -g 1001 -S appuser && adduser -S appuser -G appuser

# Establecer directorio de trabajo
WORKDIR /app

# Copiar JAR desde el stage de build
COPY --from=builder /app/target/pet-service-1.0.0.jar app.jar

# Crear directorio para credenciales de Google Cloud
RUN mkdir -p /app/credentials && chown -R appuser:appuser /app

# Cambiar a usuario no-root
USER appuser

# Exponer puerto
EXPOSE 8083

# Variables de entorno por defecto
ENV SPRING_PROFILES_ACTIVE=production
ENV SERVER_PORT=${PORT:-8083}
ENV AI_SERVICE_ENABLED=true
ENV GCS_ENABLED=true

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8083/actuator/health || exit 1

# Comando para ejecutar la aplicación
CMD ["java", "-Xmx512m", "-Xms256m", "-jar", "app.jar"] 