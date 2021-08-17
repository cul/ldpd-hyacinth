import React, { useEffect, useState } from 'react';
import { useHistory, useLocation } from 'react-router-dom';
import {
  Card, Col, Row,
} from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import {
  withQueryParams, decodeQueryParams,
} from 'use-query-params';
import * as qs from 'query-string';
import { queryParamsConfig, encodeAndStringifySearch } from '../../utils/encodeAndStringifySearch';

import DigitalObjectList from './DigitalObjectList';
import FacetSidebar from './search/FacetSidebar';
import ResultCountAndOptions from './search/ResultCountAndOptions';

import ContextualNavbar from '../shared/ContextualNavbar';
import PaginationBar from '../shared/PaginationBar';
import GraphQLErrors from '../shared/GraphQLErrors';
import { getDigitalObjectsQuery } from '../../graphql/digitalObjects';
import QueryForm from './search/QueryForm';
import SelectedFacetsBar from './search/SelectedFacetsBar';

// NOTE: We are using the use-query-params library to automatically parse
// query params only. The library is able to update the browser
// history (thus making the back button work), but there isn't a way to
// re-render the page. UseEffect hooks don't seem to notice any
// history changes made by the external library.

const DigitalObjectSearch = ({ query }) => {
  const [pageNumber, setPageNumber] = useState(query.pageNumber);
  const [limit, setLimit] = useState(query.perPage);
  const [offset] = useState((query.pageNumber - 1) * limit);
  const [totalObjects, setTotalObjects] = useState(0);
  const [searchParams, setSearchParams] = useState({ searchType: query.searchType, searchTerms: query.q, filters: query.filters });
  const [orderBy, setOrderBy] = useState(query.orderBy);

  const {
    loading, error, data, refetch,
  } = useQuery(
    getDigitalObjectsQuery, {
      variables: {
        limit,
        offset: (pageNumber - 1) * limit,
        searchParams,
        orderBy: { field: orderBy.split(' ')[0], direction: orderBy.split(' ')[1] },
      },
      onCompleted: (searchData) => { setTotalObjects(searchData.digitalObjects.totalCount); },
    },
  );

  const history = useHistory();
  const location = useLocation();

  // Runs when the component is initialized as well as when location.search
  // or history.location changes.
  // NOTE: Apollo seems to not requery when the variables are the same.
  useEffect(() => {
    // Decodes query parameters with the same logic used to instantiate the component
    const queryParams = {
      searchType: undefined,
      q: undefined,
      pageNumber: undefined,
      perPage: undefined,
      filters: undefined,
      orderBy: undefined,
      ...qs.parse(location.search),
    };

    const {
      searchType, q, filters, pageNumber: newPageNumber, perPage: newPerPage, orderBy: newOrderBy,
    } = decodeQueryParams(queryParamsConfig, queryParams);

    setSearchParams({ searchTerms: q, searchType, filters });
    setLimit(newPerPage);
    setPageNumber(newPageNumber);
    setOrderBy(newOrderBy);
    refetch();
  }, [location.search, history.location]);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { digitalObjects: { nodes, facets, totalCount } } = data;

  const updateQueryParameters = (newParams) => {
    const search = encodeAndStringifySearch(newParams);
    history.push(`/digital_objects?${search}`);
  };

  const onPageNumberClick = (newOffset) => {
    updateQueryParameters({
      searchType: searchParams.searchType,
      pageNumber: (newOffset / limit) + 1,
      perPage: limit,
      filters: searchParams.filters,
      q: searchParams.query,
    });
  };

  const sameValues = (array1, array2) => {
    if (array1.length === array2.length) {
      return !array1.find(val => array2.indexOf(val) === -1);
    }
    return false;
  };
  const isFacetCurrent = (fieldName, value) => {
    const detector = filter => ((filter.field === fieldName) && sameValues(filter.values, [value]));
    const { filters = [] } = searchParams;
    return filters ? filters.find(detector) : false;
  };

  const onFacetSelect = (fieldName, value) => {
    const detector = filter => ((filter.field === fieldName) && sameValues(filter.values, [value]));
    const others = filter => ((filter.field !== fieldName) || !sameValues(filter.values, [value]));
    const { filters = [] } = searchParams;
    const isFiltered = filters ? filters.find(detector) : false;
    const updatedFilters = isFiltered
      ? filters.filter(others)
      : [...filters, { field: fieldName, values: [value] }];

    updateQueryParameters({
      searchType: searchParams.searchType,
      pageNumber: 1,
      perPage: limit,
      filters: updatedFilters,
      q: searchParams.searchTerms,
      orderBy,
    });
  };

  const onQueryChange = (value) => {
    updateQueryParameters({
      searchType: value.searchType,
      pageNumber: 1,
      perPage: limit,
      filters: searchParams.filters,
      q: value.searchTerms,
      orderBy,
    });
  };

  const onPerPageChange = (value) => {
    updateQueryParameters({
      searchType: searchParams.searchType,
      pageNumber: 1,
      perPage: value,
      filters: searchParams.filters,
      q: searchParams.searchTerms,
      orderBy,
    });
  };

  // orderBy is a string that is a combination of the field and direction.
  // Example: 'LAST_MODIFIED ASC'
  const onOrderByChange = (newOrderBy) => {
    updateQueryParameters({
      searchType: searchParams.searchType,
      pageNumber: 1,
      perPage: limit,
      filters: searchParams.filters,
      q: searchParams.query,
      orderBy: newOrderBy,
    });
  };

  const docsFound = nodes.length > 0;

  return (
    <>
      <ContextualNavbar
        title="Digital Objects"
        rightHandLinks={[{ label: 'New Digital Object', link: '/digital_objects/new' }]}
      />

      <QueryForm
        searchTerms={query.q}
        searchType={query.searchType}
        onQueryChange={onQueryChange}
      />

      <SelectedFacetsBar
        selectedFacets={searchParams.filters}
        facets={facets}
        onRemoveFacet={onFacetSelect}
      />

      {
        docsFound && (
          <ResultCountAndOptions
            orderBy={orderBy}
            onOrderByChange={onOrderByChange}
            onPerPageChange={onPerPageChange}
            totalCount={totalCount}
            limit={limit}
            offset={offset}
            pageNumber={pageNumber}
            searchParams={searchParams}
          />
        )
      }

      <Row>
        <Col md={8}>
          { docsFound
            ? (
              <DigitalObjectList
                className="digital-object-search-results"
                digitalObjects={nodes}
                displayParentIds
                displayProjects

                orderBy={orderBy}
                totalCount={totalCount}
                limit={limit}
                offset={offset}
                pageNumber={pageNumber}
                searchParams={searchParams}
                path={location.pathname}
                disableDrag
              />
            )
            : <Card><Card.Header>No Digital Objects found.</Card.Header></Card>
          }
        </Col>
        <Col md={4}>
          <FacetSidebar
            facets={facets}
            isFacetCurrent={isFacetCurrent}
            onFacetSelect={onFacetSelect}
            selectedFacets={searchParams.filters}
          />
        </Col>
      </Row>

      <PaginationBar
        offset={(pageNumber - 1) * limit}
        limit={limit}
        totalItems={totalObjects}
        onClick={onPageNumberClick}
      />
    </>
  );
};

export default withQueryParams(queryParamsConfig, DigitalObjectSearch);
