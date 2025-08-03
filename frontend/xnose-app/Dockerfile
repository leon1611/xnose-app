# Multi-stage build para Frontend
FROM node:18-alpine AS builder

# Instalar Expo CLI globalmente
RUN npm install -g @expo/cli

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY . .

# Build para web
RUN npx expo export:web

# Runtime stage con nginx
FROM nginx:alpine

# Copiar configuración de nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar archivos build desde el stage anterior
COPY --from=builder /app/web-build /usr/share/nginx/html

# Exponer puerto
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# Comando para ejecutar nginx
CMD ["nginx", "-g", "daemon off;"] 