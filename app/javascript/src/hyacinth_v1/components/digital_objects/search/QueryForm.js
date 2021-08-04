import React, { useState } from 'react';
import { Form, Col, Row } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { capitalize } from 'lodash';
import TextInput from '../../shared/forms/inputs/TextInput';
import SelectInput from '../../shared/forms/inputs/SelectInput';

import SearchButton from '../../shared/buttons/SearchButton';

const searchTypes = ['KEYWORD', 'TITLE', 'IDENTIFER'];

function QueryForm(props) {
  const { value, onQueryChange } = props;
  const [queryValue, setQueryValue] = useState(value);

  const submitHandler = (ev) => {
    ev.preventDefault();
    onQueryChange(queryValue);
  };

  const changeHandler = (changed) => {
    setQueryValue(changed);
    return changed;
  };

  return (
    <Form onSubmit={submitHandler} className="flex-column mt-3">
      <Form.Group as={Row}>
        <SelectInput
          xs={4}
          sm={3}
          md={2}
          size="sm"
          value="KEYWORD"
          onChange={changeHandler}
          options={searchTypes.map(t => ({ label: capitalize(t), value: t }))}
          disabled
        />
        <TextInput
          sm={null}
          size="sm"
          value={queryValue}
          placeholder="Search..."
          onChange={changeHandler}
        />
        <Col xs="auto"><SearchButton onClick={submitHandler} /></Col>
      </Form.Group>
    </Form>
  );
}

QueryForm.defaultProps = {
  value: '',
};

QueryForm.propTypes = {
  value: PropTypes.string,
  onQueryChange: PropTypes.func.isRequired,
};

export default QueryForm;
