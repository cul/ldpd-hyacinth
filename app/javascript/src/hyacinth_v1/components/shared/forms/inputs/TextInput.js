import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

let uniqueTextInputIdCounter = 0;

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
    const controlId = inputName || `textInput-${uniqueTextInputIdCounter += 1}`;
    return (
      <Col sm={10} style={{ alignSelf: 'center' }} {...rest}>
        <Form.Control
          id={controlId} // id is required for associated label linkage
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
  inputName: null,
  placeholder: null,
  size: null,
  disabled: false,
};

TextInput.propTypes = {
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  placeholder: PropTypes.string,
  value: PropTypes.string.isRequired,
  size: PropTypes.string,
  disabled: PropTypes.bool,
};

export default TextInput;
