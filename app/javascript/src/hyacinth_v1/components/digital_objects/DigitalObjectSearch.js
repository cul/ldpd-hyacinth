import React, { useEffect } from 'react';
import { useHistory } from 'react-router-dom';
import {
  Card, Col, Row,
} from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { useQueryParams } from 'use-query-params';
import {
  decodedQueryParamstoSearchParams,
  encodeSessionSearchParams,
  locationSearchToSearchParams,
  queryParamsConfig,
  searchParamsToLocationSearch,
} from '../../utils/digitalObjectSearchParams';

import DigitalObjectList from './DigitalObjectList';
import FacetSidebar from './search/FacetSidebar';
import ResultCountAndOptions from './search/ResultCountAndOptions';

import ContextualNavbar from '../shared/ContextualNavbar';
import PaginationBar from '../shared/PaginationBar';
import GraphQLErrors from '../shared/GraphQLErrors';
import { getDigitalObjectsQuery } from '../../graphql/digitalObjects';
import QueryForm from './search/QueryForm';
import SelectedFacetsBar from './search/SelectedFacetsBar';

const searchParamsToVariables = (searchParams) => {
  const {
    searchTerms, searchType, filters, limit, offset, orderBy,
  } = searchParams;
  return {
    limit,
    offset,
    searchParams: { searchTerms, searchType, filters },
    orderBy: { field: orderBy.split(' ')[0], direction: orderBy.split(' ')[1] },
  };
};

// NOTE: We are using the use-query-params library to automatically parse
// query params into initial search params. The component pushes changes to
// history (thus making the back button work), and re-renders
// are via refetch in a history listener.
const DigitalObjectSearch = () => {
  const [queryParams] = useQueryParams(queryParamsConfig);
  const searchParams = decodedQueryParamstoSearchParams({ ...queryParams });
  const {
    loading, error, data, refetch,
  } = useQuery(
    getDigitalObjectsQuery, {
      variables: searchParamsToVariables(searchParams),
      onCompleted: () => {
        // sessionStorage is used to retrieve last search in other components
        encodeSessionSearchParams(searchParams);
      },
    },
  );

  const history = useHistory();
  // useEffect allows the history listener to be cleaned up when navigating to another component
  useEffect(() => {
    const stopListener = history.listen(
      (location) => {
        const refetchVariables = searchParamsToVariables(locationSearchToSearchParams(location));
        refetch({ variables: refetchVariables });
      },
    );
    return stopListener;
  });
  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { digitalObjects: { nodes, facets, totalCount } } = data;

  const updateSearch = (update) => {
    const newLocationQuery = searchParamsToLocationSearch({ ...searchParams, ...update });
    // push to history directly to listen for changes
    history.push(`/digital_objects?${newLocationQuery}`);
  };

  const {
    searchTerms, searchType, filters, limit, offset, orderBy,
  } = searchParams;

  const onPageNumberClick = (newOffset) => {
    updateSearch({ offset: newOffset });
  };

  const sameValues = (array1, array2) => {
    if (array1.length === array2.length) {
      return !array1.find((val) => array2.indexOf(val) === -1);
    }
    return false;
  };
  const isFacetCurrent = (fieldName, value) => {
    const detector = (filter) => ((filter.field === fieldName) && sameValues(filter.values, [value]));
    return filters ? filters.find(detector) : false;
  };

  const onFacetSelect = (fieldName, value) => {
    const detector = (filter) => ((filter.field === fieldName) && sameValues(filter.values, [value]));
    const others = (filter) => ((filter.field !== fieldName) || !sameValues(filter.values, [value]));
    const isFiltered = filters ? filters.find(detector) : false;
    const updatedFilters = isFiltered
      ? filters.filter(others)
      : [...filters, { field: fieldName, values: [value] }];

    updateSearch({ offset: 0, filters: updatedFilters });
  };

  const onQueryChange = (value) => {
    updateSearch({ ...value, offset: 0 });
  };

  const onPerPageChange = (value) => {
    updateSearch({ offset: 0, limit: value });
  };

  // orderBy is a string that is a combination of the field and direction.
  // Example: 'LAST_MODIFIED ASC'
  const onOrderByChange = (newOrderBy) => {
    updateSearch({
      ...searchParams,
      offset: 0,
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
        searchTerms={searchParams.searchTerms}
        searchType={searchParams.searchType}
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
            searchParams={{ searchTerms, searchType, filters }}
          />
        )
      }

      <Row>
        <Col md={8}>
          {
            docsFound ? (
              <DigitalObjectList
                className="digital-object-search-results"
                digitalObjects={nodes}
                displayParentIds
                displayProjects
                fromSearch
                orderBy={orderBy}
                totalCount={totalCount}
                offset={offset}
              />
            ) : <Card><Card.Header>No Digital Objects found.</Card.Header></Card>
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
        offset={offset}
        limit={limit}
        totalItems={totalCount}
        onClick={onPageNumberClick}
      />
    </>
  );
};

export default DigitalObjectSearch;
