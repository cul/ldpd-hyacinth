import {
  encodeArray, decodeArray,
  encodeObject, decodeObject,
} from 'use-query-params';

const FilterArrayParam = {
  encode: (filters) => {
    const encodeFilter = (filter) => {
      const { field, value } = filter;
      return encodeObject(Object.fromEntries([[field, value]]),'::','__');
    };
    return encodeArray(filters.map(encodeFilter));
  },
  decode: (arrayStr) => {
    const decodeFilter = (encoded) => {
      const [field, value] = Object.entries(decodeObject(encoded,'::','__'))[0];
      return { field, value };
    };
    return decodeArray(arrayStr).map(decodeFilter) || [];
  },
};

export default FilterArrayParam;
