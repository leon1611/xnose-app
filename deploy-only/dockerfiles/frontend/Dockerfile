# Dockerfile para Frontend (React Native/Expo)
FROM node:18-alpine

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

# Exponer puerto
EXPOSE 19000

# Comando para ejecutar la aplicación
CMD ["npm", "start"] 