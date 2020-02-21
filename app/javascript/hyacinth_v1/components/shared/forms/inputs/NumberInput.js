import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

// For this input, `value` must be a number or null. The value passed to the callback
// function will either be null or a number. The input will be passed an empty string
// instead of null when there isn't a value.
class NumberInput extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { value } } = event;
    const { onChange } = this.props;
    onChange(value.length === 0 ? null : parseInt(value, 10));
  }

  render() {
    const {
      inputName, value, onChange, ...rest
    } = this.props;

    return (
      <Col sm={10} style={{ alignSelf: 'center' }} {...rest}>
        <Form.Control
          type="number"
          name={inputName}
          value={value === null ? '' : value}
          onChange={this.onChangeHandler}
        />
      </Col>
    );
  }
}

NumberInput.defaultProps = {
  inputName: null,
  value: null,
};

NumberInput.propTypes = {
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.number,
};

export default NumberInput;
