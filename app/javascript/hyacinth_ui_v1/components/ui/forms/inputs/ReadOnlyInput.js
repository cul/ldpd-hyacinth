import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

class ReadOnlyInput extends React.PureComponent {
  render() {
    const { value } = this.props;

    return (
      <Col sm={8} style={{ alignSelf: 'center' }}>
        <Form.Control
          type="text"
          value={value}
          size="sm"
          readOnly
          disabled
        />
      </Col>
    );
  }
}

ReadOnlyInput.propTypes = {
  value: PropTypes.string.isRequired,
};

export default ReadOnlyInput;
