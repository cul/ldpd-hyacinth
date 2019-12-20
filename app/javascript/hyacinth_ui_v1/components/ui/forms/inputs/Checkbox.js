import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

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
      <Col sm={8} style={{ alignSelf: 'center' }} {...rest}>
        <Form.Check type="checkbox" id={inputName}>
          <Form.Check.Input type="checkbox" onChange={this.onChangeHandler} name={inputName} checked={value} disabled={disabled} />
          <Form.Check.Label>{label}</Form.Check.Label>
          { helpText && <p className="text-muted">{helpText}</p> }
        </Form.Check>
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
