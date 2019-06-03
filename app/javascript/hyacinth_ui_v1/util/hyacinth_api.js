import axios from 'axios';

const instance = axios.create({
  baseURL: '/api/v1',
  responseType: 'json',
  headers: { 'X-Key-Inflection': 'camel' },
});

export default instance;
