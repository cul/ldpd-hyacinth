import axios from 'axios';

const instance = axios.create({
  baseURL: '/api/v1',
  responseType: 'json'
});

export default instance;
