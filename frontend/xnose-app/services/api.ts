// Servicio de API para comunicación con backend
import axios, { AxiosInstance, AxiosResponse } from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { API_CONFIG } from '../config/api';

// Tipos de datos
export interface User {
  id: string;
  username: string;
  role: 'USER' | 'ADMIN';
}

export interface AuthResponse {
  user: User;
}

export interface Owner {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
}

export interface Pet {
  id: string;
  name: string;
  breed: string;
  age: number;
  sex: 'MALE' | 'FEMALE';
  profileImageUrl: string;
  noseImageUrl: string;
  ownerId: string;
}

export interface Alert {
  id: string;
  petId: string;
  type: 'LOST' | 'FOUND';
  location: string;
  description: string;
  createdAt: string;
  petProfileImageUrl?: string;
  petName?: string;
}

export interface ScanResponse {
  match: boolean;
  petId?: string;
  confidence: number;
}

export interface VisualComparisonResponse {
  uploaded_image_features: {
    feature_models: string[];
    feature_dimensions: Record<string, number>;
  };
  registered_pets_comparison: Array<{
    petId: string;
    petName: string;
    breed: string;
    final_score: number;
    model_scores: Record<string, number>;
    match: boolean;
    noseImageUrl?: string;
  }>;
  top_matches: Array<{
    petId: string;
    petName: string;
    breed: string;
    final_score: number;
    model_scores: Record<string, number>;
    match: boolean;
    noseImageUrl?: string;
  }>;
  analysis_summary: {
    total_pets_compared: number;
    matching_pets: number;
    best_match_score: number;
    threshold_used: number;
    confidence_boost: number;
    feature_models_used: string[];
  };
}

class ApiService {
  private authApi: AxiosInstance;
  private ownerApi: AxiosInstance;
  private petApi: AxiosInstance;
  private alertApi: AxiosInstance;

  constructor() {
    // Configurar APIs para cada servicio
    this.authApi = axios.create({
      baseURL: API_CONFIG.AUTH_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.ownerApi = axios.create({
      baseURL: API_CONFIG.OWNER_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.petApi = axios.create({
      baseURL: API_CONFIG.PET_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.alertApi = axios.create({
      baseURL: API_CONFIG.ALERT_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Configurar interceptores para cada API
    this.setupInterceptors(this.authApi);
    this.setupInterceptors(this.ownerApi);
    this.setupInterceptors(this.petApi);
    this.setupInterceptors(this.alertApi);
  }

  private setupInterceptors(api: AxiosInstance) {
    api.interceptors.request.use(
      async (config) => {
        // Log de la petición para depuración
        console.log(`🌐 ${config.method?.toUpperCase()} ${config.url}`, {
          data: config.data,
          headers: config.headers,
        });
        
        return config;
      },
      (error) => {
        console.error('❌ Error en interceptor de request:', error);
        return Promise.reject(error);
      }
    );

    // Interceptor para manejar respuestas y errores
    api.interceptors.response.use(
      (response: AxiosResponse) => {
        console.log(`✅ ${response.config.method?.toUpperCase()} ${response.config.url} - Status: ${response.status}`);
        return response;
      },
      (error) => {
        console.error('❌ Error en respuesta:', {
          url: error.config?.url,
          method: error.config?.method,
          status: error.response?.status,
          data: error.response?.data,
          message: error.message,
        });
        return Promise.reject(error);
      }
    );
  }

  // Función para limpiar datos de autenticación
  private async clearAuthData(): Promise<void> {
    try {
      await AsyncStorage.removeItem('user');
      console.log('🧹 Datos de autenticación limpiados');
    } catch (error) {
      console.error('❌ Error al limpiar datos de autenticación:', error);
    }
  }

  // Función para verificar si el usuario está autenticado
  async isAuthenticated(): Promise<boolean> {
    try {
      const user = await AsyncStorage.getItem('user');
      return !!user;
    } catch (error) {
      console.error('❌ Error al verificar autenticación:', error);
      return false;
    }
  }

  // Autenticación
  async login(username: string, password: string): Promise<AuthResponse> {
    try {
      console.log('🔐 Iniciando login para usuario:', username);
      const response = await this.authApi.post(API_CONFIG.ENDPOINTS.AUTH.LOGIN, {
        username,
        password,
      });
      
      const userData = {
        id: response.data.id.toString(),
        username: response.data.username,
        role: response.data.role as 'USER' | 'ADMIN'
      };
      
      // Guardar usuario
      await AsyncStorage.setItem('user', JSON.stringify(userData));
      
      console.log('✅ Login exitoso');
      return {
        user: userData
      };
    } catch (error) {
      console.error('❌ Error en login:', error);
      throw error;
    }
  }

  async register(username: string, email: string, password: string): Promise<AuthResponse> {
    try {
      console.log('📝 Iniciando registro para usuario:', username);
      const response = await this.authApi.post(API_CONFIG.ENDPOINTS.AUTH.REGISTER, {
        username,
        email,
        password,
      });
      
      const userData = {
        id: response.data.id.toString(),
        username: response.data.username,
        role: response.data.role as 'USER' | 'ADMIN'
      };
      
      // Guardar usuario
      await AsyncStorage.setItem('user', JSON.stringify(userData));
      
      console.log('✅ Registro exitoso');
      return {
        user: userData
      };
    } catch (error) {
      console.error('❌ Error en registro:', error);
      throw error;
    }
  }

  async logout(): Promise<void> {
    try {
      console.log('🚪 Cerrando sesión');
      await AsyncStorage.removeItem('user');
      console.log('✅ Sesión cerrada');
    } catch (error) {
      console.error('❌ Error al cerrar sesión:', error);
      throw error;
    }
  }

  // Propietarios
  async getOwners(): Promise<Owner[]> {
    try {
      console.log('👥 Obteniendo lista de propietarios');
      
      // Obtener el usuario actual
      const userJson = await AsyncStorage.getItem('user');
      if (!userJson) {
        console.log('⚠️ No hay usuario autenticado, obteniendo todos los propietarios');
        const response = await this.ownerApi.get(`${API_CONFIG.ENDPOINTS.OWNERS}`);
        return response.data;
      }
      
      const user = JSON.parse(userJson);
      console.log('👤 Usuario autenticado:', user);
      
      // Obtener propietarios del usuario específico
      const response = await this.ownerApi.get(`${API_CONFIG.ENDPOINTS.OWNERS}/user/${user.id}`);
      
      console.log('📊 Respuesta completa:', response);
      console.log('📋 Datos de propietarios:', response.data);
      console.log(`✅ ${response.data.length} propietarios obtenidos para usuario ${user.username}`);
      
      return response.data;
    } catch (error: any) {
      console.error('❌ Error al obtener propietarios:', error);
      console.error('❌ Detalles del error:', {
        message: error.message,
        response: error.response?.data,
        status: error.response?.status,
        url: error.config?.url
      });
      throw error;
    }
  }

  async getOwner(id: string): Promise<Owner> {
    try {
      console.log(`👤 Obteniendo propietario con ID: ${id}`);
      const response = await this.ownerApi.get(`${API_CONFIG.ENDPOINTS.OWNERS}/${id}`);
      console.log('✅ Propietario obtenido');
      return response.data;
    } catch (error) {
      console.error('❌ Error al obtener propietario:', error);
      throw error;
    }
  }

  async createOwner(owner: Omit<Owner, 'id'>): Promise<Owner> {
    try {
      console.log('➕ Creando nuevo propietario:', owner.name);
      
      // Obtener el usuario actual
      const userJson = await AsyncStorage.getItem('user');
      if (!userJson) {
        throw new Error('Usuario no autenticado');
      }
      
      const user = JSON.parse(userJson);
      console.log('👤 Usuario autenticado para crear propietario:', user);
      
      // Agregar el userId al propietario
      const ownerWithUserId = {
        ...owner,
        userId: user.id
      };
      
      const response = await this.ownerApi.post(`${API_CONFIG.ENDPOINTS.OWNERS}`, ownerWithUserId);
      console.log('✅ Propietario creado exitosamente para usuario:', user.username);
      return response.data;
    } catch (error: any) {
      console.error('❌ Error al crear propietario:', error);
      throw error;
    }
  }

  async updateOwner(id: string, owner: Partial<Owner>): Promise<Owner> {
    try {
      console.log(`✏️ Actualizando propietario con ID: ${id}`);
      const response = await this.ownerApi.put(`${API_CONFIG.ENDPOINTS.OWNERS}/${id}`, owner);
      console.log('✅ Propietario actualizado');
      return response.data;
    } catch (error) {
      console.error('❌ Error al actualizar propietario:', error);
      throw error;
    }
  }

  async deleteOwner(id: string): Promise<void> {
    try {
      console.log(`🗑️ Eliminando propietario con ID: ${id}`);
      await this.ownerApi.delete(`${API_CONFIG.ENDPOINTS.OWNERS}/${id}`);
      console.log('✅ Propietario eliminado');
    } catch (error) {
      console.error('❌ Error al eliminar propietario:', error);
      throw error;
    }
  }

  // Mascotas
  async getPets(): Promise<Pet[]> {
    try {
      console.log('🐕 Obteniendo lista de mascotas');
      
      // Obtener el usuario actual
      const userJson = await AsyncStorage.getItem('user');
      if (!userJson) {
        console.log('⚠️ No hay usuario autenticado, obteniendo todas las mascotas');
        const response = await this.petApi.get(`${API_CONFIG.ENDPOINTS.PETS}`);
        return response.data;
      }
      
      const user = JSON.parse(userJson);
      console.log('👤 Usuario autenticado:', user);
      
      // Obtener mascotas del usuario específico (privadas)
      const response = await this.petApi.get(`${API_CONFIG.ENDPOINTS.PETS}/user/${user.id}`);
      
      console.log(`✅ ${response.data.length} mascotas obtenidas para usuario ${user.username}`);
      return response.data;
    } catch (error) {
      console.error('❌ Error al obtener mascotas:', error);
      throw error;
    }
  }

  async getPet(id: string): Promise<Pet> {
    try {
      console.log(`🐕 Obteniendo mascota con ID: ${id}`);
      const response = await this.petApi.get(`${API_CONFIG.ENDPOINTS.PETS}/${id}`);
      console.log('✅ Mascota obtenida');
      return response.data;
    } catch (error) {
      console.error('❌ Error al obtener mascota:', error);
      throw error;
    }
  }

  async createPet(petData: FormData): Promise<Pet> {
    try {
      console.log('➕ Creando nueva mascota');
      
      // Obtener el usuario actual
      const userJson = await AsyncStorage.getItem('user');
      if (!userJson) {
        throw new Error('Usuario no autenticado');
      }
      
      const user = JSON.parse(userJson);
      console.log('👤 Usuario autenticado para crear mascota:', user);
      
      // Agregar el userId al FormData
      petData.append('userId', user.id);
      
      const response = await this.petApi.post(`${API_CONFIG.ENDPOINTS.PETS}/with-images`, petData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      console.log('✅ Mascota creada exitosamente para usuario:', user.username);
      return response.data;
    } catch (error) {
      console.error('❌ Error al crear mascota:', error);
      throw error;
    }
  }

  async updatePet(id: string, petData: FormData): Promise<Pet> {
    try {
      console.log(`✏️ Actualizando mascota con ID: ${id}`);
      const response = await this.petApi.put(`${API_CONFIG.ENDPOINTS.PETS}/${id}/images`, petData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      console.log('✅ Mascota actualizada');
      return response.data;
    } catch (error) {
      console.error('❌ Error al actualizar mascota:', error);
      throw error;
    }
  }

  async deletePet(id: string): Promise<void> {
    try {
      console.log(`🗑️ Eliminando mascota con ID: ${id}`);
      await this.petApi.delete(`${API_CONFIG.ENDPOINTS.PETS}/${id}`);
      console.log('✅ Mascota eliminada');
    } catch (error) {
      console.error('❌ Error al eliminar mascota:', error);
      throw error;
    }
  }

  // Alertas
  async getAlerts(): Promise<Alert[]> {
    try {
      console.log('🚨 Obteniendo lista de alertas (compartidas globalmente)');
      
      // Las alertas son compartidas entre todos los usuarios
      const response = await this.alertApi.get(API_CONFIG.ENDPOINTS.ALERTS);
      
      console.log(`✅ ${response.data.length} alertas obtenidas (compartidas entre todos los usuarios)`);
      return response.data;
    } catch (error) {
      console.error('❌ Error al obtener alertas:', error);
      throw error;
    }
  }

  async getAlert(id: string): Promise<Alert> {
    try {
      console.log(`🚨 Obteniendo alerta con ID: ${id}`);
      const response = await this.alertApi.get(`${API_CONFIG.ENDPOINTS.ALERTS}/${id}`);
      console.log('✅ Alerta obtenida');
      return response.data;
    } catch (error) {
      console.error('❌ Error al obtener alerta:', error);
      throw error;
    }
  }

  async createAlert(alert: Omit<Alert, 'id' | 'createdAt'>): Promise<Alert> {
    try {
      console.log('➕ Creando nueva alerta (compartida globalmente)');
      
      // Las alertas son compartidas, no necesitan userId específico
      const response = await this.alertApi.post(API_CONFIG.ENDPOINTS.ALERTS, alert);
      console.log('✅ Alerta creada exitosamente (compartida entre todos los usuarios)');
      return response.data;
    } catch (error) {
      console.error('❌ Error al crear alerta:', error);
      throw error;
    }
  }

  async updateAlert(id: string, alert: Partial<Alert>): Promise<Alert> {
    try {
      console.log(`✏️ Actualizando alerta con ID: ${id}`);
      const response = await this.alertApi.put(`${API_CONFIG.ENDPOINTS.ALERTS}/${id}`, alert);
      console.log('✅ Alerta actualizada');
      return response.data;
    } catch (error) {
      console.error('❌ Error al actualizar alerta:', error);
      throw error;
    }
  }

  async deleteAlert(id: string): Promise<void> {
    try {
      console.log(`🗑️ Eliminando alerta con ID: ${id}`);
      await this.alertApi.delete(`${API_CONFIG.ENDPOINTS.ALERTS}/${id}`);
      console.log('✅ Alerta eliminada');
    } catch (error) {
      console.error('❌ Error al eliminar alerta:', error);
      throw error;
    }
  }

  // Escaneo
  async scanPet(image: FormData): Promise<ScanResponse> {
    try {
      console.log('🔍 Escaneando imagen de mascota');
      const response = await this.petApi.post(API_CONFIG.ENDPOINTS.SCAN, image, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      console.log('✅ Escaneo completado');
      return response.data;
    } catch (error) {
      console.error('❌ Error al escanear mascota:', error);
      throw error;
    }
  }

  // Comparación Visual
  async visualComparison(image: FormData): Promise<VisualComparisonResponse> {
    try {
      console.log('🔍 Realizando comparación visual de huella nasal');
      const response = await this.petApi.post(API_CONFIG.ENDPOINTS.VISUAL_COMPARISON, image, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      console.log('✅ Comparación visual completada');
      return response.data;
    } catch (error) {
      console.error('❌ Error en comparación visual:', error);
      throw error;
    }
  }
}

export const apiService = new ApiService(); 