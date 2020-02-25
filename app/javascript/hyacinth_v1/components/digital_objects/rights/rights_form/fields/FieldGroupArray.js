import React from 'react';
import produce from 'immer';
import PropTypes from 'prop-types';

import FieldGroup from './FieldGroup';

/* This is a copy of the class for the metadata form, these can be merged later when the use the same strategy to update state */

class FieldGroupArray extends React.Component {
  onChange(index, updates) {
    const { onChange } = this.props;

    onChange((obj) => {
      const updated = updates(obj[index]);
      return produce(obj, (draft) => {
        draft[index] = updated;
      });
    });
  }

  addHandler = (index) => {
    const { onChange, defaultValue } = this.props;

    onChange(produce((draft) => {
      draft.splice(index + 1, 0, defaultValue);
    }));
  }

  moveHandler = (move, index) => {
    const { value, onChange } = this.props;

    switch (move) {
      case 'up':
        if (index !== 0) {
          onChange(produce((draft) => {
            [draft[index - 1], draft[index]] = [draft[index], draft[index - 1]];
          }));
        }
        break;
      case 'down':
        if (index !== (value.length - 1)) {
          onChange(produce((draft) => {
            [draft[index], draft[index + 1]] = [draft[index + 1], draft[index]];
          }));
        }
        break;
      default:
        break;
    }
  }

  removeHandler = (index) => {
    const { onChange } = this.props;

    onChange(produce((draft) => {
      delete draft[index];
    }));
  }

  render() {
    const { value, dynamicFieldGroup, defaultValue } = this.props;

    return (
      value.map((v, i) => (
        <FieldGroup
          key={`${dynamicFieldGroup.stringKey}_${i}`}
          value={v}
          index={i}
          defaultValue={defaultValue}
          dynamicFieldGroup={dynamicFieldGroup}
          onChange={updates => this.onChange(i, updates)}
          addHandler={() => this.addHandler(i)}
          removeHandler={() => this.removeHandler(i)}
          moveHandler={move => this.moveHandler(move, i)}
        />
      ))
    );
  }
}

FieldGroupArray.propTypes = {
  onChange: PropTypes.func.isRequired,
  dynamicFieldGroup: PropTypes.shape({
    stringKey: PropTypes.string.isRequired,
    displayLabel: PropTypes.string.isRequired,
    isRepeatable: PropTypes.bool.isRequired,
  }).isRequired,
  value: PropTypes.arrayOf(PropTypes.object).isRequired,
  defaultValue: PropTypes.shape(PropTypes.any).isRequired,
};

export default FieldGroupArray;
