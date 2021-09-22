import React from 'react';
import PropTypes from 'prop-types';
import produce from 'immer';
import {
  Row, Col, Form, InputGroup, Button,
} from 'react-bootstrap';
import FontAwesomeIcon from '../../../../utils/lazyFontAwesome';

const TextInputWithAddAndRemove = (props) => {
  const onChangeHandler = (index, event) => {
    const { target: { value: newValue } } = event;
    const { values, onChange } = props;

    const updatedValues = produce(values, (draft) => {
      draft[index] = newValue;
    });

    onChange(updatedValues);
  };

  const addHandler = (index) => {
    const { values, onChange, defaultValue } = props;

    const updatedValues = produce(values, (draft) => {
      draft.splice(index + 1, 0, defaultValue);
    });

    onChange(updatedValues);
  };

  const removeHandler = (index) => {
    const { values, onChange } = props;

    const updatedValues = produce(values, (draft) => {
      draft.splice(index, 1);
    });

    onChange(updatedValues);
  };

  const {
    onChange, inputName, values, placeholder, ...rest
  } = props;

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
                  onChange={(e) => onChangeHandler(i, e)}
                  placeholder={placeholder}
                />
                <Button variant="danger" size="sm" onClick={() => removeHandler(i)}>
                  <FontAwesomeIcon icon="minus" />
                </Button>
                <Button variant="success" size="sm" onClick={() => addHandler(i)}>
                  <FontAwesomeIcon icon="plus" />
                </Button>
              </InputGroup>
            </Col>
          </Form.Group>
        ))
      }
    </Col>
  );
};

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
