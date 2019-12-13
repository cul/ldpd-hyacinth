import React from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  Row, Col, Form, InputGroup, Button,
} from 'react-bootstrap';

class TextInputWithAddAndRemove extends React.PureComponent {
  onChangeHandler(index, event) {
    const { target: { value: newValue } } = event;
    const { values, onChange } = this.props;

    const updatedValues = produce(values, (draft) => {
      draft[index] = newValue;
    });

    onChange(updatedValues);
  }

  addHandler = (index) => {
    const { values, onChange, defaultValue } = this.props;

    const updatedValues = produce(values, (draft) => {
      draft.splice(index + 1, 0, defaultValue);
    });

    onChange(updatedValues);
  }

  removeHandler = (index) => {
    const { values, onChange } = this.props;

    const updatedValues = produce(values, (draft) => {
      draft.splice(index, 1);
    });

    onChange(updatedValues);
  }

  render() {
    const {
      onChange, inputName, values, placeholder, ...rest
    } = this.props;

    return (
      <Col sm={10} style={{ alignSelf: 'center' }} {...rest}>
        {
          (values.length === 0 ? [''] : values).map((v, i) => (
            <Form.Group as={Row} key={i}>
              <Col sm={12}>
                <InputGroup>
                  <Form.Control
                    type="text"
                    name={inputName}
                    value={v}
                    onChange={e => this.onChangeHandler(i, e)}
                    placeholder={placeholder}
                  />
                  <InputGroup.Append>
                    <Button variant="danger" size="sm" onClick={() => this.removeHandler(i)}>
                      <FontAwesomeIcon icon="minus" />
                    </Button>
                    <Button variant="success" size="sm" onClick={() => this.addHandler(i)}>
                      <FontAwesomeIcon icon="plus" />
                    </Button>
                  </InputGroup.Append>
                </InputGroup>
              </Col>
            </Form.Group>
          ))
        }
      </Col>
    );
  }
}

TextInputWithAddAndRemove.defaultProps = {
  defaultValue: '',
};

TextInputWithAddAndRemove.propTypes = {
  defaultValue: PropTypes.string,
  inputName: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  values: PropTypes.array.isRequired,
};

export default TextInputWithAddAndRemove;
