import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';

class SelectInput extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { name, value } } = event;
    const { onChange } = this.props;

    onChange(name, value);
  }

  render() {
    const {
      name, value, options,
    } = this.props;

    return (
      <Form.Control
        as="select"
        name={name}
        value={value}
        onChange={this.onChangeHandler}
        size="sm"
      >
        <option>Choose One...</option>
        {
          options.map(o => (
            <option key={o.value} value={o.value}>{o.label}</option>
          ))
        }
      </Form.Control>

    );
  }
}

SelectInput.propTypes = {
  name: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.string.isRequired,
      label: PropTypes.string.isRequired,
    }),
  ).isRequired,
};

export default SelectInput;
