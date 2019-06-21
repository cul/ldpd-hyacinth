import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form } from 'react-bootstrap';

class TextInputGroup extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { name, value } } = event;
    const { onChange } = this.props;

    onChange(name, value);
  }

  render() {
    const {
      label, inputName, value,
    } = this.props;

    return (
      <Form.Group as={Row}>
        <Form.Label column sm={4} className="text-right">{label}</Form.Label>
        <Col sm={8} style={{ alignSelf: 'center' }}>
          <Form.Control
            type="text"
            name={inputName}
            value={value}
            onChange={this.onChangeHandler}
            size="sm"
          />
        </Col>
      </Form.Group>
    );
  }
}

TextInputGroup.propTypes = {
  label: PropTypes.string.isRequired,
  inputName: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
};

export default TextInputGroup;
