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
  all: () => instance.get('/projects'),
  get: stringKey => instance.get(`/projects/${stringKey}`),
  create: '',
  update: '',
  delete: '',
};

export const enabledDynamicFields = {
  all: (project, digitalObjectType) => (
    instance.get(`/projects/${project}/enabled_dynamic_fields/${digitalObjectType}`)
  ),
};

export const digitalObject = {
  search: () => instance.get('/digital_objects/search'),
  get: id => instance.get(`/digital_objects/${id}`),
  create: data => instance.post('/digital_objects', data),
  update: (id, data) => instance.patch(`/digital_objects/${id}`, data),
};


export const vocabularies = {
  all: () => instance.get('/vocabularies'),
};

export const vocabulary = stringKey => ({
  get: () => instance.get(`/vocabularies/${stringKey}`),
  terms: () => ({
    search: query => instance.get(`/vocabularies/${stringKey}/terms?${query}`),
    all: () => instance.get(`/vocabularies/${stringKey}/terms`),
  }),
});
