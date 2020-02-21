import { useState } from 'react';
import { isEmpty } from 'lodash';
import produce from 'immer';

// Returns true if all the values are considered blank or empty.
const isBlank = (value) => {
  if (value === null || value === undefined) return true;

  if (value instanceof Array) {
    return (isEmpty(value)) ? true : value.every(isBlank);
  }

  switch (typeof value) {
    case 'object':
      return (isEmpty(value)) ? true : Object.values(value).every(isBlank);
    case 'boolean': // type of array needs to be checked differently
      return !value;
    case 'string':
      return isEmpty(value);
    default:
      return false;
  }
};

// Used to enable sections within a form. If `data` is not blank, enabled should
// be true. If enabled is ever set to false after being initialized the clear
// function should be called.
export const useEnabled = (data, clear) => {
  const [enabled, setEnabled] = useState(!isBlank(data));
  const setEnabledAndClear = (value) => {
    setEnabled(value);
    if (!value) clear();
  };

  return [enabled, setEnabledAndClear];
};

export const useHash = (initialHash) => {
  // TODO: check that initialHash is an object but not an array
  // TODO: could this hook potentially work with arrays
  // (typeof initialHash  === 'object') && !(initialHash instanceof Array)
  const [hash, setHash] = useState(initialHash);

  const setHashViaKey = (key, update) => setHash(prevHash => produce(prevHash, (draft) => {
    if (typeof update === 'function') {
      const updated = update(prevHash[key]);
      draft[key] = updated;
    }

    if (typeof update === 'object') {
      draft[key] = update;
    }
  }));

  return [hash, setHashViaKey];
};
