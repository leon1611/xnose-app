// Configuración de API para comunicación con servicios backend
const getLocalIP = (): string => {
  if (__DEV__) {
    return '192.168.0.104';
  }
  return 'tu-ip-publica-o-dominio.com';
};

export const API_CONFIG = {
  // Base URL para todas las peticiones (Gateway Service)
  BASE_URL: `http://${getLocalIP()}:8080`,
  
  // URLs específicas para cada servicio
  AUTH_URL: `http://${getLocalIP()}:8080`,
  OWNER_URL: `http://${getLocalIP()}:8080`,
  PET_URL: `http://${getLocalIP()}:8080`, // Usar Gateway en puerto 8080
  ALERT_URL: `http://${getLocalIP()}:8080`,
  
  // Endpoints específicos
  ENDPOINTS: {
    AUTH: {
      BASE: '/auth',
      LOGIN: '/auth/login',
      REGISTER: '/auth/register',
      HEALTH: '/auth/health'
    },
    OWNERS: '/owners',
    PETS: '/pets',
    ALERTS: '/alerts',
    SCAN: '/pets/scan',
    VISUAL_COMPARISON: '/pets/visual-comparison',
    AI: '/ai', // Nuevo endpoint para AI Service
  },
  
  // Timeouts
  TIMEOUT: 30000, // 30 segundos
};

export const getApiUrl = (endpoint: string) => `${API_CONFIG.BASE_URL}${endpoint}`;

// Función para obtener URL específica del auth service
export const getAuthUrl = (endpoint: string) => `${API_CONFIG.AUTH_URL}${endpoint}`; 