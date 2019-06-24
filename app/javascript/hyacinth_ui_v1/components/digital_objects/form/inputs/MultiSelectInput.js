import React from 'react';
import PropTypes from 'prop-types';
import { Col } from 'react-bootstrap';
import Select from 'react-select';

class MultiSelectInput extends React.PureComponent {
  onChangeHandler = (newValues, actionType) => {
    const { inputName, values, onChange } = this.props;
    switch (actionType.action) {
      case 'select-option':
        onChange(newValues);
        break;
      case 'remove-value':
        onChange(values.filter(f => f.value !== actionType.removedValue.value));
        break;
      default:
        break;
    }
  }

  render() {
    const {
      inputName, values, options,
    } = this.props;

    return (
      <Col sm={8} style={{ alignSelf: 'center' }}>
        <Select
          placeholder="Select one or more..."
          value={values}
          name={inputName}
          onChange={this.onChangeHandler}
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
}

MultiSelectInput.propTypes = {
  inputName: PropTypes.string.isRequired,
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
