import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';


export const BASE_URL = "http://192.168.0.101:8000"; // Adres API

export const apiLink = {
    mechanics: `${BASE_URL}/api/mechanics/`,
    clients: `${BASE_URL}/api/clients/`,
    cars: `${BASE_URL}/api/cars/`,
    token: `${BASE_URL}/api/token/`,
    visits: `${BASE_URL}/api/visits/`,
  };

const api = axios.create({
  baseURL: BASE_URL, // Bazowy URL z config.js
});

api.interceptors.request.use(
  async (config) => {
    const token = await AsyncStorage.getItem('access');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);


export default api;
