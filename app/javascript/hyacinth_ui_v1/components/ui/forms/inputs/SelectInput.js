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
      inputName, value, options, onChange, ...rest
    } = this.props;

    return (
      <Col sm={10} style={{ alignSelf: 'center' }} {...rest}>
        <Form.Control
          as="select"
          name={inputName}
          value={value}
          onChange={this.onChangeHandler}
        >
          <option value="">Select one...</option>
          {
            options.map(o => (
              <option key={o.value} value={o.value}>{o.label}</option>
            ))
          }
        </Form.Control>
      </Col>
    );
  }
}

SelectInput.propTypes = {
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
      label: PropTypes.string.isRequired,
    }),
  ).isRequired,
};

export default SelectInput;
