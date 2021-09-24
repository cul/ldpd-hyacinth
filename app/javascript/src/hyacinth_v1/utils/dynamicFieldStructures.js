import { merge } from 'lodash';

const keepEnabledFields = (enabledFieldIds, children) => children.map((c) => {
  switch (c.type) {
    case 'DynamicFieldGroup':
      c.children = keepEnabledFields(enabledFieldIds, c.children);
      return c.children.length > 0 ? c : null;
    case 'DynamicField':
      if (enabledFieldIds.includes(c.id)) return c;
      // if the ids are fetched in queries mixing ID scalars and JSON, strings must be compared
      if (enabledFieldIds.includes(String(c.id))) return c;
      return null;
    default:
      return c;
  }
}).filter((c) => c !== null);

export const enabledDynamicFieldIds = (enabledDynamicFields) => {
  const enabledFieldIds = [];
  enabledDynamicFields.forEach((enabledField) => {
    const { dynamicField, ...rest } = enabledField;
    if (rest.enabled) enabledFieldIds.push(dynamicField.id);
  });
  return enabledFieldIds;
};

export const filterDynamicFieldCategories = (dynamicFieldCategories, enabledDynamicFields) => {
  const enabledFieldIds = enabledDynamicFieldIds(enabledDynamicFields);
  return dynamicFieldCategories.map((cat) => {
    cat.children = keepEnabledFields(enabledFieldIds, cat.children);
    return cat;
  }).filter((cat) => cat.children.length > 0);
};

const defaultFieldValue = {
  string: '',
  textarea: '',
  integer: null,
  boolean: false,
  select: '',
  date: '',
  controlled_term: {},
};

export const emptyDescriptiveMetadata = (dynamicFields, newObject) => {
  dynamicFields.forEach((i) => {
    switch (i.type) {
      case 'DynamicFieldGroup':
        newObject[i.stringKey] = [emptyDescriptiveMetadata(i.children, {})];
        break;
      case 'DynamicField':
        newObject[i.stringKey] = defaultFieldValue[i.fieldType];
        break;
      default:
        break;
    }
  });

  return newObject;
};

export const emptyDataForCategories = (filteredCategories) => {
  const emptyData = {};
  filteredCategories.forEach((category) => {
    emptyDescriptiveMetadata(category.children, emptyData);
  });
  return emptyData;
};

const isPrimitive = (value) => Object(value) !== value;

export const padEmptyData = (dataToPad, padData, key) => {
  const value = dataToPad[key];
  if (Array.isArray(value) && value.length > 1) {
    const template = padData[key][0];
    value.forEach((e, i) => {
      if (i > 0) {
        merge(e, merge({}, template, e));
      } else if (!isPrimitive(e)) {
        Object.keys(e).forEach((childKey) => {
          padEmptyData(e, template, childKey);
        });
      }
    });
  } else if (!isPrimitive(value)) {
    const template = padData[key];
    merge(value, merge({}, template, value));
    Object.keys(value).forEach((childKey) => {
      padEmptyData(value, template, childKey);
    });
  }
};

export const padForEnabledFields = (currentData, emptyData) => {
  Object.keys(currentData).forEach((key) => padEmptyData(currentData, emptyData, key));
  return currentData;
};
