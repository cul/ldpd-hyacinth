import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

class PlainText extends React.PureComponent {
  render() {
    const { value, inputName } = this.props;

    return (
      <Col sm={8} style={{ alignSelf: 'center' }}>
        <Form.Control
          plaintext
          readOnly
          id={inputName}
          defaultValue={value}
          size="sm"
        />
      </Col>
    );
  }
}

PlainText.propTypes = {
  value: PropTypes.string.isRequired,
};

export default PlainText;
