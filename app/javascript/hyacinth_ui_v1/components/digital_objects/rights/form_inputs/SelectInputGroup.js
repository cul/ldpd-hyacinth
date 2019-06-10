import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col, Form } from 'react-bootstrap';

class SelectInputGroup extends React.PureComponent {
  onChangeHandler = (event) => {
    const { target: { name, value } } = event;
    const { onChange } = this.props;

    onChange(name, value);
  }

  render() {
    const {
      label, inputName, value, options,
    } = this.props;

    return (
      <Form.Group as={Row} className="mb-1">
        <Form.Label column sm={4} className="text-right">{label}</Form.Label>
        <Col sm={8} style={{ alignSelf: 'center' }}>
          <Form.Control
            as="select"
            name={inputName}
            value={value}
            onChange={this.onChangeHandler}
            size="sm"
            placeholder="choose one"
          >
            <option>Choose One...</option>
            {
              options.map(o => (
                <option key={o.value} value={o.value}>{o.label}</option>
              ))
            }
          </Form.Control>
        </Col>
      </Form.Group>
    );
  }
}

SelectInputGroup.propTypes = {
  label: PropTypes.string.isRequired,
  inputName: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.string.isRequired,
      label: PropTypes.string.isRequired,
    }),
  ).isRequired,
};

export default SelectInputGroup;
