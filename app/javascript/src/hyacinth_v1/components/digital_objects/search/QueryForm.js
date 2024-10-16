import React, { useState } from 'react';
import { Form, Col, Row } from 'react-bootstrap';
import PropTypes from 'prop-types';
import { capitalize } from 'lodash';
import TextInput from '../../shared/forms/inputs/TextInput';
import SelectInput from '../../shared/forms/inputs/SelectInput';

import SearchButton from '../../shared/buttons/SearchButton';
import RemoveButton from '../../shared/buttons/RemoveButton';

const searchTypes = ['KEYWORD', 'TITLE', 'IDENTIFIER'];

function QueryForm({
  searchTerms, searchType, onQueryChange, clearSearch,
}) {
  const [queryType, setQueryType] = useState(searchType);
  const [queryValue, setQueryValue] = useState(searchTerms);

  const submitHandler = (ev) => {
    ev.preventDefault();
    onQueryChange({ searchTerms: queryValue, searchType: queryType });
  };

  const valueChangeHandler = (changed) => {
    setQueryValue(changed);
    return changed;
  };

  const typeChangeHandler = (changed) => {
    setQueryType(changed);
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
          value={queryType}
          onChange={typeChangeHandler}
          options={searchTypes.map((t) => ({ label: capitalize(t), value: t }))}
          inputName="queryType"
        />
        <TextInput
          sm={null}
          size="sm"
          value={queryValue}
          placeholder="Search..."
          onChange={valueChangeHandler}
          inputName="queryValue"
        />
        <Col xs="auto"><RemoveButton aria-label="Clear Search" onClick={clearSearch} /></Col>
        <Col xs="auto"><SearchButton aria-label="Submit Search" onClick={submitHandler} /></Col>
      </Form.Group>
    </Form>
  );
}

QueryForm.defaultProps = {
  searchTerms: '',
  searchType: 'KEYWORD',
};

QueryForm.propTypes = {
  searchTerms: PropTypes.string,
  searchType: PropTypes.string,
  onQueryChange: PropTypes.func.isRequired,
  clearSearch: PropTypes.func.isRequired,
};

export default QueryForm;
