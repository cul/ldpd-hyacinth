import React from 'react';
import produce from 'immer';
import PropTypes from 'prop-types';

import FieldGroup from './FieldGroup';

const FieldGroupArray = (props) => {
  const {
    value, onChange, defaultValue, dynamicFieldGroup,
  } = props;

  const onChangeWrapper = (index, newValue) => {
    const nextValue = produce(value, (draft) => {
      draft[index] = newValue;
    });

    return onChange(nextValue);
  };

  const addHandler = (index) => {
    const nextValue = produce(value, (draft) => {
      draft.splice(index + 1, 0, defaultValue);
    });

    onChange(nextValue);
  };

  const moveHandler = (move, index) => {
    switch (move) {
      case 'up':
        if (index !== 0) {
          const nextValue = produce(value, (draft) => {
            [draft[index - 1], draft[index]] = [draft[index], draft[index - 1]];
          });
          onChange(nextValue);
        }
        break;
      case 'down':
        if (index !== (value.length - 1)) {
          const nextValue = produce(value, (draft) => {
            [draft[index], draft[index + 1]] = [draft[index + 1], draft[index]];
          });
          onChange(nextValue);
        }
        break;
      default:
        break;
    }
  };

  const removeHandler = (index) => {
    const nextValue = produce(value, (draft) => {
      delete draft[index];
    });

    onChange(nextValue);
  };

  return (
    value.map((v, i) => (
      <FieldGroup
        key={`${dynamicFieldGroup.stringKey}_${i}`}
        value={v}
        index={i}
        defaultValue={defaultValue}
        dynamicFieldGroup={dynamicFieldGroup}
        onChange={newValue => onChangeWrapper(i, newValue)}
        addHandler={() => addHandler(i)}
        removeHandler={() => removeHandler(i)}
        moveHandler={move => moveHandler(move, i)}
      />
    ))
  );
};

FieldGroupArray.propTypes = {
  onChange: PropTypes.func.isRequired,
  dynamicFieldGroup: PropTypes.shape({
    stringKey: PropTypes.string.isRequired,
    displayLabel: PropTypes.string.isRequired,
    isRepeatable: PropTypes.bool.isRequired,
  }).isRequired,
  value: PropTypes.arrayOf(PropTypes.object).isRequired,
  defaultValue: PropTypes.objectOf(PropTypes.any).isRequired,
};

export default FieldGroupArray;
