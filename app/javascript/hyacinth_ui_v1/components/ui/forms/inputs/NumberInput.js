import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

class NumberInput extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { value } } = event;
    const { onChange } = this.props;

    onChange(value);
  }

  render() {
    const { inputName, value, onChange, ...rest } = this.props;

    return (
      <Col sm={10} style={{ alignSelf: 'center' }} {...rest}>
        <Form.Control
          type="number"
          name={inputName}
          value={value}
          onChange={this.onChangeHandler}
        />
      </Col>
    );
  }
}

NumberInput.propTypes = {
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
};

export default NumberInput;
