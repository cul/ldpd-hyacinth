import {
  encodeArray, decodeArray,
  encodeObject, decodeObject,
} from 'use-query-params';

const FilterArrayParam = {
  encode: (filters) => {
    const encodeFilter = (filter) => {
      const { field, values } = filter;
      return encodeObject(Object.fromEntries([[field, values[0]]]), '::', '__');
    };
    return encodeArray([filters].flat().map(encodeFilter));
  },
  decode: (arrayStr) => {
    const decodeFilter = (encoded) => {
      const [field, value] = Object.entries(decodeObject(encoded, '::', '__'))[0];
      return { field, values: [value] };
    };

    const decodedArray = decodeArray(arrayStr);
    return decodedArray == null ? decodedArray : decodedArray.map(decodeFilter);
  },
};

export default FilterArrayParam;
