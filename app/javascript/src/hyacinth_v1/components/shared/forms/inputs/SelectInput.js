import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

class SelectInput extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { value } } = event;
    const { onChange } = this.props;

    onChange(value);
  }

  render() {
    const {
      inputName, value, options, onChange, size, disabled, aria, ...rest
    } = this.props;

    return (
      <Col sm={10} style={{ alignSelf: 'center' }} {...rest}>
        <Form.Select
          name={inputName}
          value={value}
          size={size}
          disabled={disabled}
          aria-label={aria.label || inputName}
          onChange={this.onChangeHandler}
        >
          <option key="" value="">Select one...</option>
          {
            options.map((o) => (
              <option key={o.value} value={o.value}>{o.label}</option>
            ))
          }
        </Form.Select>
      </Col>
    );
  }
}

SelectInput.defaultProps = {
  inputName: null,
  size: null,
  disabled: false,
  aria: { label: null },
};

SelectInput.propTypes = {
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  size: PropTypes.string,
  disabled: PropTypes.bool,
  aria: PropTypes.shape(
    {
      label: PropTypes.string,
    },
  ),
  options: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
      label: PropTypes.string.isRequired,
    }),
  ).isRequired,
};

export default SelectInput;
