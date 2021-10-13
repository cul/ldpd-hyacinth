import React from 'react';
import PropTypes from 'prop-types';
import {
  Col, Dropdown, FloatingLabel, Form, Row, ToggleButtonGroup, ToggleButton,
} from 'react-bootstrap';

const filterFunctionLabels = {
  STARTS_WITH: 'starting with',
  CONTAINS: 'containing',
};

const Controls = (props) => {
  const {
    fieldName, orderBy, setOrderBy, facetFilter, setFacetFilter,
  } = props;
  const changeFacetFilter = (newFilter) => {
    const prev = facetFilter || { filterFunction: 'CONTAINS' };
    if (newFilter.length > 1) {
      setFacetFilter({ ...prev, filterValue: newFilter });
    } else if (prev.filterValue) {
      setFacetFilter({ ...prev, filterValue: null });
    }
  };
  const changeFilterFunction = (newFunction) => {
    setFacetFilter({ ...facetFilter, filterFunction: newFunction });
  };
  return (
    <>
      <Form.Group as={Row} className="mb-1">
        <Col sm={4}>
          <Dropdown>
            <Dropdown.Toggle variant="outline-primary" id="filter-function">Find values</Dropdown.Toggle>
            <Dropdown.Menu>
              <Dropdown.Item onClick={() => changeFilterFunction('STARTS_WITH')}>{filterFunctionLabels.STARTS_WITH}</Dropdown.Item>
              <Dropdown.Item onClick={() => changeFilterFunction('CONTAINS')}>{filterFunctionLabels.CONTAINS}</Dropdown.Item>
            </Dropdown.Menu>
          </Dropdown>
        </Col>
        <Col sm>
          <FloatingLabel size="sm" label={`${filterFunctionLabels[facetFilter.filterFunction]}...`} controlId="floatingFilterValue">
            <Form.Control type="text" size="sm" placeholder="..." onChange={(e) => { changeFacetFilter(e.currentTarget.value); }} />
          </FloatingLabel>
        </Col>
      </Form.Group>
      <ToggleButtonGroup
        type="radio"
        name={`facet-${fieldName}-orderBy`}
        defaultValue={orderBy}
        onChange={setOrderBy}
        className="mb-2 d-flex"
      >
        <ToggleButton
          id={`facet-${fieldName}-orderBy-index`}
          variant="secondary"
          value="INDEX"
          className="flex-fill"
        >
          Sorted by Value
        </ToggleButton>
        <ToggleButton
          id={`facet-${fieldName}-orderBy-count`}
          variant="secondary"
          value="COUNT"
          className="flex-fill"
        >
          Sorted by Count
        </ToggleButton>
      </ToggleButtonGroup>
    </>
  );
};
Controls.defaultProps = {
  facetFilter: null,
};
Controls.propTypes = {
  fieldName: PropTypes.string.isRequired,
  orderBy: PropTypes.string.isRequired,
  setOrderBy: PropTypes.func.isRequired,
  facetFilter: PropTypes.shape({
    filterValue: PropTypes.string,
    filterFunction: PropTypes.string.isRequired,
  }),
  setFacetFilter: PropTypes.func.isRequired,
};

export default Controls;
