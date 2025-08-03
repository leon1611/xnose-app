# Multi-stage build para AI Service
FROM python:3.11-slim AS builder

# Instalar dependencias del sistema para compilación
RUN apt-get update && apt-get install -y \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir --user -r requirements.txt

# Runtime stage
FROM python:3.11-slim

# Instalar dependencias del sistema para runtime
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Crear usuario no-root
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Establecer directorio de trabajo
WORKDIR /app

# Copiar dependencias de Python desde el stage de build
COPY --from=builder /root/.local /home/appuser/.local

# Copiar código fuente
COPY --chown=appuser:appuser . .

# Cambiar a usuario no-root
USER appuser

# Agregar .local/bin al PATH
ENV PATH=/home/appuser/.local/bin:$PATH

# Exponer puerto
EXPOSE 8000

# Variables de entorno por defecto
ENV PYTHONUNBUFFERED=1
ENV HOST=0.0.0.0
ENV PORT=8000
ENV LOG_LEVEL=INFO
ENV SIMILARITY_THRESHOLD=0.80
ENV CONFIDENCE_BOOST=0.1

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Comando para ejecutar la aplicación
CMD uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 1 