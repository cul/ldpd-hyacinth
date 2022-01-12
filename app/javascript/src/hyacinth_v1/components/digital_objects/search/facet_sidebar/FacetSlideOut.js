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

export const facetSearchVariables = (fieldName, searchState) => {
  const searchParams = objectSearchParams();
  const { offset, limit, orderBy, facetFilter } = searchState;
  const variables = {
    fieldName, offset, searchParams, orderBy: { field: orderBy }, limit: (limit + 1),
  };
  if (facetFilter.filterValue) {
    const newFilter = { field: fieldName, values: [facetFilter.filterValue], matchType: facetFilter.filterFunction };
    searchParams.filters.push(newFilter);
    variables.facetFilter = newFilter;
  }
  return variables;
};

const responseData = (data) => {
  return (data?.facetValues?.nodes ? data.facetValues.nodes : []);
};

const FacetSlideOut = (props) => {
  const {
    fieldName, limit, onFacetSelect, selectedValues, displayLabel, hasMore,
  } = props;
  const [searchState, setSearchState] = useState({ show: false, offset: 0, limit: limit, orderBy: 'INDEX', facetFilter: { filterValue: null, filterFunction: 'CONTAINS' } })

  const [getValues, { error, data, refetch }] = useLazyQuery(
    facetValuesQuery, { variables: facetSearchVariables(fieldName, searchState) },
  );
  if (!hasMore) return <></>;
  const handleShow = () => {
    // set show state flag
    setSearchState({...searchState, show: true});
    // get values for search
    if (data) {
      const updatedVariables = facetSearchVariables(fieldName, searchState);
      refetch({ variables: updatedVariables });
    } else {
      getValues();
    }
  };
  const handleClose = () => {
    const blankFilter = {...searchState.facetFilter, filterValue: null };
    setSearchState({...searchState, facetFilter: blankFilter, offset: 0, show: false});
  };
  const handleFilter = (filterChange) => {
    setSearchState({...searchState, facetFilter: filterChange, offset: 0});
  };
  const handlePaging = (pageOffset) => {
    setSearchState({...searchState, offset: pageOffset});
  };
  const handleSort = (sortValue) => {
    setSearchState({...searchState, orderBy: sortValue, offset: 0});
  };
  // wrap facetSelect function to remove filter if set
  const wrapFacetSelect = (wrapFieldName, wrapValue) => {
    const blankFilter = {...searchState.facetFilter, filterValue: null };
    setSearchState({...searchState, facetFilter: blankFilter, offset: 0});
    onFacetSelect(wrapFieldName, wrapValue);
  };

  const values = responseData(data);
  const { show, offset } = searchState;
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
            orderBy={searchState.orderBy}
            setOrderBy={handleSort}
            facetFilter={searchState.facetFilter}
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
