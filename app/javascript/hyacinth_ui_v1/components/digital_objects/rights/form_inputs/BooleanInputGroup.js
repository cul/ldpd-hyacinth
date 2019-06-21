import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form } from 'react-bootstrap';

import BooleanRadioButtons from '../../../layout/forms/BooleanRadioButtons';

class BooleanInputGroup extends React.PureComponent {
  render() {
    const {
      label, inputName, onChange, value,
    } = this.props;

    return (
      <Form.Group as={Row}>
        <Form.Label column sm={4} className="text-right">{label}</Form.Label>
        <Col sm={8} style={{ alignSelf: 'center' }}>
          <BooleanRadioButtons name={inputName} value={value} onChange={onChange} />
        </Col>
      </Form.Group>
    );
  }
}

BooleanInputGroup.propTypes = {
  label: PropTypes.string.isRequired,
  inputName: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.bool.isRequired,
};

export default BooleanInputGroup;
