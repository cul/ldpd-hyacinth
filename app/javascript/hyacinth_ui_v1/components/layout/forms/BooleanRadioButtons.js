import React from 'react';
import PropTypes from 'prop-types';
import { Form } from 'react-bootstrap';

class BooleanRadioButtons extends React.Component {
  onRadioButtonChange = (event) => {
    const {
      target: {
        value, checked,
      },
    } = event;

    const { name, onChange } = this.props;

    onChange(name, checked && value === 'yes');
  }

  render() {
    const { value } = this.props;

    return (
      <>
        <Form.Check
          inline
          type="radio"
          label="Yes"
          value="yes"
          checked={value}
          onChange={this.onRadioButtonChange}
        />

        <Form.Check
          inline
          type="radio"
          value="no"
          label="No"
          checked={!value && value !== null}
          onChange={this.onRadioButtonChange}
        />
      </>
    );
  }
}

BooleanRadioButtons.propTypes = {
  name: PropTypes.string.isRequired,
  value: PropTypes.bool.isRequired,
  onChange: PropTypes.func.isRequired,
};

export default BooleanRadioButtons;
