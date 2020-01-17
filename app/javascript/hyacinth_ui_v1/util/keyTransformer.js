import { camelCase, snakeCase } from 'lodash';

class KeyTransformer {
  /**
   * Returns a recursively key-transformed copy of the given
   * object or array without modifying the input.
   */
  transformKeys = (obj, transformFunction) => {
    if (Array.isArray(obj)) {
      return obj.map(v => this.transformKeys(v, transformFunction));
    }

    if (obj !== null && obj.constructor === Object) {
      return Object.keys(obj).reduce(
        (result, key) => ({
          ...result,
          [transformFunction(key)]: this.transformKeys(obj[key], transformFunction),
        }),
        {},
      );
    }
    return obj;
  }

  /**
   * Returns a recursively camelCase key-transformed copy of the given
   * object or array without modifying the input.
   */
  deepCamelCase = (obj) => {
    return this.transformKeys(obj, camelCase);
  }

  /**
   * Returns a recursively snake_case key-transformed copy of the given
   * object or array without modifying the input.
   */
  deepSnakeCase = (obj) => {
    return this.transformKeys(obj, snakeCase);
  }
}

const keyTransformer = new KeyTransformer();

export default keyTransformer;
