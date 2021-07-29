
// Given the dynamic field configuration generates what the default set of values should be.
const defaultFieldValue = {
  string: '',
  textarea: '',
  integer: null,
  boolean: false,
  select: '',
  date: '',
  controlled_term: {},
};

export function defaultFieldValues(dynamicFieldsConfig) {
  const defaults = {};

  dynamicFieldsConfig.forEach((i) => {
    switch (i.type) {
      case 'DynamicFieldGroup':
        defaults[i.stringKey] = [defaultFieldValues(i.children)];
        break;
      case 'DynamicField':
        defaults[i.stringKey] = defaultFieldValue[i.fieldType];
        break;
      default:
        break;
    }
  });

  return defaults;
}

export function mergeDefaultValues(dynamicFieldsConfig, initialValues) {
  const values = {};

  dynamicFieldsConfig.forEach((i) => {
    switch (i.type) {
      case 'DynamicFieldGroup':
        values[i.stringKey] = (initialValues[i.stringKey] || [{}]).map(v => mergeDefaultValues(i.children, v));
        break;
      case 'DynamicField':
        values[i.stringKey] = initialValues[i.stringKey] || defaultFieldValue[i.fieldType];
        break;
      default:
        break;
    }
  });

  return values;
}
