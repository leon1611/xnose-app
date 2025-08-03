// Configuración de API para producción
export const API_CONFIG = {
  BASE_URL: 'https://xnose-gateway-service-431223568957.us-central1.run.app',
  AI_SERVICE_URL: 'https://xnose-ai-service-jrms6vnyga-uc.a.run.app',
  TIMEOUT: 30000,
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 1000,
};

export const ENDPOINTS = {
  // Auth endpoints
  LOGIN: '/api/auth/login',
  REGISTER: '/api/auth/register',
  REFRESH_TOKEN: '/api/auth/refresh',
  
  // Owner endpoints
  OWNERS: '/api/owners',
  OWNER_PROFILE: '/api/owners/profile',
  
  // Pet endpoints
  PETS: '/api/pets',
  PET_BY_ID: (id: string) => `/api/pets/${id}`,
  PET_IMAGES: (id: string) => `/api/pets/${id}/images`,
  
  // Alert endpoints
  ALERTS: '/api/alerts',
  ALERT_BY_ID: (id: string) => `/api/alerts/${id}`,
  
  // AI Service endpoints
  AI_SCAN: '/scan',
  AI_REGISTER: '/register',
  AI_HEALTH: '/health',
};

export default API_CONFIG; 