import React from 'react';
import PropTypes from 'prop-types';
import { Col, Form } from 'react-bootstrap';

let uniqueReadOnlyInputIdCounter = 0;

class ReadOnlyInput extends React.PureComponent {
  render() {
    const { value, inputName, ...rest } = this.props;

    return (
      <Col sm={10} style={{ alignSelf: 'center' }} {...rest}>
        <Form.Control
          id={inputName || `checkbox-${uniqueReadOnlyInputIdCounter++}`} // id is required for associated label linkage
          type="text"
          value={value}
          readOnly
          disabled
        />
      </Col>
    );
  }
}

ReadOnlyInput.defaultProps = {
  value: '',
  inputName: null,
};

ReadOnlyInput.propTypes = {
  value: PropTypes.string,
  inputName: PropTypes.string,
};

export default ReadOnlyInput;
