import { isEmpty } from 'lodash';

// Removes given key from obj and any nested obj. Returns a new obj.
//
// This method ONLY works on objs that have primative types, if there are functions or
// other types of data within your object this method will not know how to transform those.
export const deepKeyRemove = (obj, key) => {
  const removeKey = (k, v) => ((k === key) ? undefined : v);
  return JSON.parse(JSON.stringify(obj, removeKey));
};

// Removes __typename key from nested object with method defined above.
//
// This method ONLY work with an hash that has primative types.
export const removeTypename = (hash) => deepKeyRemove(hash, '__typename');

// Removes nulls, empty hashes, arrays and strings.

// This method ONLY work with an hash that has primative types.
export const removeEmptyKeys = (data) => {
  const removeKey = (k, v) => {
    if (v === null || v === undefined) return undefined;
    if ((typeof v === 'string') || (typeof v === 'object')) {
      return isEmpty(v) ? undefined : v;
    }
    return v;
  };

  return JSON.parse(JSON.stringify(data, removeKey));
};
