import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

let uniqueCheckboxIdCounter = 0;

class Checkbox extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { checked } } = event;
    const { onChange } = this.props;

    onChange(checked);
  }

  render() {
    const {
      label, inputName, helpText, value, disabled, onChange, ...rest
    } = this.props;

    return (
      <Col {...rest}>
        <Form.Check
          id={inputName || `checkbox-${uniqueCheckboxIdCounter++}`} // id is required for associated label linkage
          name={inputName}
          type="checkbox"
          label={label}
          onChange={this.onChangeHandler}
          checked={value}
          disabled={disabled}
        />
        { helpText && <p className="text-muted">{helpText}</p> }
      </Col>
    );
  }
}

Checkbox.defaultProps = {
  inputName: '',
  label: '',
  helpText: null,
  disabled: false,
};

Checkbox.propTypes = {
  label: PropTypes.string,
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  disabled: PropTypes.bool,
  value: PropTypes.bool.isRequired,
  helpText: PropTypes.string,
};

export default Checkbox;
