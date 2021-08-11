import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

class TextInput extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { value } } = event;
    const { onChange } = this.props;

    onChange(value);
  }

  render() {
    const {
      onChange, inputName, value, size, disabled, placeholder, ...rest
    } = this.props;

    return (
      <Col sm={10} style={{ alignSelf: 'center' }} {...rest}>
        <Form.Control
          type="text"
          tabIndex="0"
          name={inputName}
          value={value}
          size={size}
          onChange={this.onChangeHandler}
          placeholder={placeholder}
          disabled={disabled}
        />
      </Col>
    );
  }
}

TextInput.defaultProps = {
  size: null,
  disabled: false,
};

TextInput.propTypes = {
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  size: PropTypes.string,
  disabled: PropTypes.bool,
};

export default TextInput;
