import React from 'react';
import produce from 'immer';
import PropTypes from 'prop-types';

import FieldGroup from './FieldGroup';

class FieldGroupArray extends React.Component {
  onChange(index, newValue) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[index] = newValue;
    });

    onChange(nextValue);
  }

  addHandler = (index) => {
    const { value, onChange, defaultValue } = this.props;

    const nextValue = produce(value, (draft) => {
      draft.splice(index + 1, 0, defaultValue);
    });

    onChange(nextValue);
  }

  moveHandler = (move, index) => {
    const { value, onChange } = this.props;

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
  }

  removeHandler = (index) => {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      delete draft[index];
    });

    onChange(nextValue);
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
          onChange={newValue => this.onChange(i, newValue)}
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
  defaultValue: PropTypes.objectOf(PropTypes.any).isRequired,
};

export default FieldGroupArray;
