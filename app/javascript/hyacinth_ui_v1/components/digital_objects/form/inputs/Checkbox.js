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
      label, inputName, value,
    } = this.props;

    return (
      <Col sm={8} style={{ alignSelf: 'center' }}>
        <Form.Check
          className="py-1"
          type="checkbox"
          value={value}
          id={inputName}
          name={inputName}
          label={label}
          onChange={this.onChangeHandler}
        />
      </Col>
    );
  }
}

Checkbox.propTypes = {
  label: PropTypes.string.isRequired,
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.bool.isRequired,
};

export default Checkbox;
