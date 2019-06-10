import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form } from 'react-bootstrap';

class CheckboxInputGroup extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { name, checked } } = event;
    const { onChange } = this.props;

    onChange(name, checked);
  }

  render() {
    const {
      label, inputName, value,
    } = this.props;

    return (
      <Form.Check
        className="py-1"
        type="checkbox"
        value={value}
        id={inputName}
        name={inputName}
        label={label}
        onChange={this.onChangeHandler}
      />
    );
  }
}

CheckboxInputGroup.propTypes = {
  label: PropTypes.string.isRequired,
  inputName: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.bool.isRequired,
};

export default CheckboxInputGroup;
