import React from 'react';
import produce from 'immer';

import FieldGroup from './FieldGroup';

class FieldGroupArray extends React.Component {
  onChange(index, newValue) {
    const { value, onChange } = this.props;

    const nextValue = produce(value, (draft) => {
      draft[index] = newValue;
    });

    onChange(nextValue);
  }

  render() {
    const { value, dynamicFieldGroup } = this.props;

    return (
      value.map((v, i) => (
        <FieldGroup
          value={v}
          dynamicFieldGroup={dynamicFieldGroup}
          onChange={newValue => this.onChange(i, newValue)}
        />
      ))
    )
  }
}

export default FieldGroupArray;
