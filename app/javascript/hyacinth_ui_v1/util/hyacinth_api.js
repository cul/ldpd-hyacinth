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
  delete: id => instance.delete(`/digital_objects/${id}`),
};


export const vocabularies = {
  all: () => instance.get('/vocabularies'),
  get: stringKey => instance.get(`/vocabularies/${stringKey}`),
};

export const vocabulary = stringKey => ({
  get: () => instance.get(`/vocabularies/${stringKey}`),
  terms: () => ({
    search: query => instance.get(`/vocabularies/${stringKey}/terms?${query}`),
    all: () => instance.get(`/vocabularies/${stringKey}/terms`),
    get: uri => instance.get(`/vocabularies/${stringKey}/terms/${uri}`),
  }),
});

export const terms = {
  search: (vocabStringKey, query) => instance.get(`/vocabularies/${vocabStringKey}/terms?${query}`),
  all: vocabStringKey => instance.get(`/vocabularies/${vocabStringKey}/terms`),
  get: (vocabStringKey, uri) => instance.get(`/vocabularies/${vocabStringKey}/terms/${uri}`),
  update: (vocabStringKey, uri, data) => instance.patch(`/vocabularies/${vocabStringKey}/terms/${uri}`, data),
  create: (vocabStringKey, data) => instance.post(`/vocabularies/${vocabStringKey}/terms`, data),
};
