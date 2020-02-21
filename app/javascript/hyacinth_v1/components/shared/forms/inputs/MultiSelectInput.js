import React from 'react';
import PropTypes from 'prop-types';
import { Col } from 'react-bootstrap';
import Select from 'react-select';

// The react-select component expects `value` and `options` to each be an object with a `label` and
// `value` key. In order to make this component more reuseable we decided that the values received
// by this component should be an array of value keys (strings). This component will map the correct
// labels to each value key and pass those on to the react-select component. The onChange prop
// function should expect to recieve an array of value keys (strings.)
function MultiSelectInput(props) {
  const {
    inputName, options, values, onChange,
  } = props;

  const onChangeHandler = (newValues, actionType) => {
    switch (actionType.action) {
      case 'select-option':
        onChange(newValues.map(v => v.value));
        break;
      case 'remove-value':
        onChange(values.filter(f => f.value !== actionType.removedValue.value));
        break;
      default:
        break;
    }
  };

  const valuesWithLabels = values.map(v => (
    { value: v, label: options.find(o => o.value === v).label }
  ));

  return (
    <Col sm={8} style={{ alignSelf: 'center' }}>
      <Select
        placeholder="Select one or more..."
        value={valuesWithLabels}
        name={inputName}
        onChange={onChangeHandler}
        options={options}
        isMulti
        isSearchable={false}
        isClearable={false}
        styles={{
          container: styles => ({ ...styles, fontSize: '.875rem', paddingTop: '.35rem' }),
        }}
      />
    </Col>
  );
}

MultiSelectInput.defaultProps = {
  inputName: '',
};

MultiSelectInput.propTypes = {
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  values: PropTypes.arrayOf(PropTypes.string).isRequired,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.string.isRequired,
      label: PropTypes.string.isRequired,
    }),
  ).isRequired,
};

export default MultiSelectInput;
