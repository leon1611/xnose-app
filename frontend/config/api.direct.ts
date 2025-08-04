// Configuración de API directa (sin Gateway) para producción
export const API_CONFIG_DIRECT = {
  AUTH_URL: 'https://xnose-auth-service-jrms6vnyga-uc.a.run.app',
  OWNER_URL: 'https://xnose-owner-service-jrms6vnyga-uc.a.run.app',
  PET_URL: 'https://xnose-pet-service-jrms6vnyga-uc.a.run.app',
  ALERT_URL: 'https://xnose-alert-service-jrms6vnyga-uc.a.run.app',
  AI_SERVICE_URL: 'https://xnose-ai-service-jrms6vnyga-uc.a.run.app',
  TIMEOUT: 30000,
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 1000,
};

export const ENDPOINTS_DIRECT = {
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

export default API_CONFIG_DIRECT; 