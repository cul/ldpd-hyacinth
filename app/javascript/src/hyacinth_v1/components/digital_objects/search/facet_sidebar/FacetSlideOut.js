import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Button, Offcanvas } from 'react-bootstrap';
import { useLazyQuery } from '@apollo/react-hooks';
import pick from 'lodash/pick';
import FacetOption from './FacetOption';
import SlideOutControls from './slide_out/Controls';
import { facetValuesQuery } from '../../../../graphql/facetValues';
import PrevNextPaginationBar from '../../../shared/PrevNextPaginationBar';
import GraphQLErrors from '../../../shared/GraphQLErrors';
import {
  decodeSessionSearchParams,
} from '../../../../utils/digitalObjectSearchParams';

const objectSearchParams = () => (
  { filters: [], ...pick(['searchTerms', 'searchType', 'filters'], decodeSessionSearchParams()) }
);

export const facetSearchVariables = (fieldName, offset, limit, orderBy, facetFilter) => {
  const searchParams = objectSearchParams();
  const variables = {
    fieldName, offset, limit, searchParams, orderBy: { field: orderBy },
  };
  if (facetFilter.filterValue) {
    const newFilter = { field: fieldName, values: [facetFilter.filterValue], matchType: facetFilter.filterFunction };
    searchParams.filters.push(newFilter);
    variables.facetFilter = newFilter;
  }
  return variables;
};

const responseData = (data) => {
  const values = (data?.facetValues?.nodes ? data.facetValues.nodes : []);
  const totalCount = data?.facetValues ? data.facetValues.totalCount : 0;
  return { totalCount, values };
};

const FacetSlideOut = (props) => {
  const {
    fieldName, limit, onFacetSelect, selectedValues, displayLabel, hasMore,
  } = props;
  const [show, setShow] = useState(false);
  const [offset, setOffset] = useState(0);
  const [orderBy, setOrderBy] = useState('INDEX');
  const [facetFilter, setFacetFilter] = useState({ filterValue: null, filterFunction: 'CONTAINS' });
  const variables = facetSearchVariables(fieldName, offset, limit + 1, orderBy, facetFilter);

  const [getValues, { error, data, refetch }] = useLazyQuery(
    facetValuesQuery, { variables },
  );
  if (!hasMore) return <></>;
  const handleShow = () => {
    // get values for search
    // set show state flag
    setShow(true);
    if (data) {
      refetch({ variables });
    } else {
      getValues();
    }
  };
  const handleClose = () => {
    setShow(false);
    setFacetFilter({ ...facetFilter, filterValue: null });
    setOffset(0);
  };
  const handleUpdate = () => {
    const updatedVariables = facetSearchVariables(fieldName, offset, limit, orderBy, facetFilter);
    refetch({ variables: updatedVariables });
  };
  const handleFilter = (filterChange) => {
    setFacetFilter(filterChange);
    handleUpdate();
  };
  const handlePaging = (pageOffset) => {
    setOffset(pageOffset);
    handleUpdate();
  };
  const handleSort = (sortValue) => {
    setOrderBy(sortValue);
    handleUpdate();
  };
  // wrap facetSelect function to remove filter if set
  const wrapFacetSelect = (wrapFieldName, wrapValue) => {
    setFacetFilter({ ...facetFilter, filterValue: null });
    setOffset(0);
    onFacetSelect(wrapFieldName, wrapValue);
  };
  // TODO changes to filter or sort should reset offset
  const { values, totalCount } = responseData(data);
  return (
    <>
      <Button variant="primary" size="sm" onClick={handleShow}>
        More
      </Button>

      <Offcanvas show={show} onHide={handleClose} placement="end">
        <Offcanvas.Header closeButton>
          <Offcanvas.Title>{displayLabel}</Offcanvas.Title>
        </Offcanvas.Header>
        <Offcanvas.Body>
          { error && <GraphQLErrors errors={error} /> }
          <SlideOutControls
            fieldName={fieldName}
            orderBy={orderBy}
            setOrderBy={handleSort}
            facetFilter={facetFilter}
            setFacetFilter={handleFilter}
          />
          {
            values.slice(0, limit).map((value) => (
              <FacetOption
                key={`option_${fieldName}_${value.value}`}
                value={value.value}
                count={value.count}
                selected={selectedValues.includes(value.value)}
                onSelect={() => wrapFacetSelect(fieldName, value.value)}
              />
            ))
          }
          <PrevNextPaginationBar pageItems={values.length} onClick={handlePaging} limit={limit} offset={offset} />
        </Offcanvas.Body>
      </Offcanvas>
    </>
  );
};

FacetSlideOut.defaultProps = {
  limit: 20,
  hasMore: false,
};

FacetSlideOut.propTypes = {
  fieldName: PropTypes.string.isRequired,
  displayLabel: PropTypes.string.isRequired,
  hasMore: PropTypes.bool,
  onFacetSelect: PropTypes.func.isRequired,
  limit: PropTypes.number,
  selectedValues: PropTypes.arrayOf(
    PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.number,
      PropTypes.bool,
    ]),
  ).isRequired,
};

export default FacetSlideOut;
