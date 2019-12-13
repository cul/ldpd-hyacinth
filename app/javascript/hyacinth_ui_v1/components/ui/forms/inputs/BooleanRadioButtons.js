import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

class BooleanRadioButtons extends React.Component {
  onRadioButtonChange = (event) => {
    const {
      target: {
        value, checked,
      },
    } = event;

    const { onChange } = this.props;

    onChange(checked && value === 'yes');
  }

  render() {
    const {
      inputName, value, onChange, ...rest
    } = this.props;

    return (
      <Col sm={8} style={{ alignSelf: 'center' }} {...rest}>
        <Form.Check
          inline
          type="radio"
          label="Yes"
          name={inputName}
          value="yes"
          checked={value}
          onChange={this.onRadioButtonChange}
        />

        <Form.Check
          inline
          type="radio"
          name={inputName}
          value="no"
          label="No"
          checked={!value && value !== null}
          onChange={this.onRadioButtonChange}
        />
      </Col>
    );
  }
}

BooleanRadioButtons.propTypes = {
  inputName: PropTypes.string,
  value: PropTypes.bool.isRequired,
  onChange: PropTypes.func.isRequired,
};

BooleanRadioButtons.defaultProps = {
  inputName: '',
};

export default BooleanRadioButtons;
