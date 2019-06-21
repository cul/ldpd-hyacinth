import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form } from 'react-bootstrap';

class ReadOnlyInputGroup extends React.PureComponent {
  render() {
    const { label, value } = this.props;

    return (
      <Form.Group as={Row}>
        <Form.Label column sm={4} className="text-right">{label}</Form.Label>
        <Col sm={8} style={{ alignSelf: 'center' }}>
          <Form.Control
            type="text"
            value={value}
            size="sm"
            readOnly
            disabled
          />
        </Col>
      </Form.Group>
    );
  }
}

ReadOnlyInputGroup.propTypes = {
  label: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
};

export default ReadOnlyInputGroup;
