import { camelCase, snakeCase } from 'lodash';

/**
 * Returns a recursively key-transformed copy of the given
 * object or array without modifying the input.
 */
const transformKeys = (obj, transformFunction) => {
  if (Array.isArray(obj)) {
    return obj.map((v) => transformKeys(v, transformFunction));
  }

  if (obj !== null && obj.constructor === Object) {
    return Object.keys(obj).reduce(
      (result, key) => ({
        ...result,
        [transformFunction(key)]: transformKeys(obj[key], transformFunction),
      }),
      {},
    );
  }
  return obj;
};

/**
 * Returns a recursively camelCase key-transformed copy of the given
 * object or array without modifying the input.
 */
export const deepCamelCase = (obj) => transformKeys(obj, camelCase);

/**
 * Returns a recursively snake_case key-transformed copy of the given
 * object or array without modifying the input.
 */
export const deepSnakeCase = (obj) => transformKeys(obj, snakeCase);
