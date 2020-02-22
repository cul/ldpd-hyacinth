import React, { useState } from 'react';
import { Form, Col } from 'react-bootstrap';
import PropTypes from 'prop-types';
import TextInput from '../../shared/forms/inputs/TextInput';

function QueryForm(props) {
  const { value, onQueryChange, onSubmit } = props;
  const [queryValue, setQueryValue] = useState(value);
  const submitHandler = (ev) => {
    ev.preventDefault();
    onQueryChange(queryValue);
    onSubmit();
  };
  const changeHandler = (changed) => {
    setQueryValue(changed);
    return changed;
  };

  return (
    <>
      <Form onSubmit={submitHandler} className="flex-column">
        <Form.Group controlId="queryFormTerm">
          <Form.Label column>Search for:</Form.Label>
          <Col className="flex-column">
            <TextInput
              value={queryValue}
              onChange={changeHandler}
            />
          </Col>
        </Form.Group>
      </Form>
    </>
  );
}

QueryForm.propTypes = {
  value: PropTypes.string,
  onQueryChange: PropTypes.func.isRequired,
  onSubmit: PropTypes.func.isRequired,
};
QueryForm.defaultProps = {
  value: '',
};

export default QueryForm;
