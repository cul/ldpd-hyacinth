import axios from 'axios';

const instance = axios.create({
  baseURL: '/api/v1',
  responseType: 'json',
  headers: { 'X-Key-Inflection': 'camel' },
});

export default instance;

export const dynamicFieldCategories = {
  all: () => instance.get('/dynamic_field_categories'),
};

export const projects = {
  search: (query) => instance.get(`/projects?${query}`),
  all: () => instance.get('/projects'),
  get: (stringKey) => instance.get(`/projects/${stringKey}`),
  create: '',
  update: '',
  delete: '',
};
