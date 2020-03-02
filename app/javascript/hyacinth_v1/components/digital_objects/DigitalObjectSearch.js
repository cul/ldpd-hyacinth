import React, { useEffect, useState } from 'react';
import { useHistory, useLocation } from 'react-router-dom';
import {
  Card, Col, Row,
} from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { NumberParam, StringParam, withQueryParams } from 'use-query-params';
import * as qs from 'query-string';

import DigitalObjectList from './DigitalObjectList';
import DigitalObjectFacets from './DigitalObjectFacets';
import ResultCountAndSortOptions from './search/ResultCountAndSortOptions';

import ContextualNavbar from '../shared/ContextualNavbar';
import PaginationBar from '../shared/PaginationBar';
import GraphQLErrors from '../shared/GraphQLErrors';
import { getDigitalObjectsQuery } from '../../graphql/digitalObjects';
import FilterArrayParam from '../../utils/filterArrayParam';
import QueryForm from './search/QueryForm';

const limit = 20;

const DigitalObjectSearch = ({ query }) => {
  const [pageNumber] = useState(query.pageNumber);
  const [offset, setOffset] = useState(((pageNumber || 1) - 1) * limit);
  const [totalObjects, setTotalObjects] = useState(0);
  const [searchParams, setSearchParams] = useState({ query: query.q, filters: query.filters });
  const {
    loading, error, data, refetch,
  } = useQuery(
    getDigitalObjectsQuery, {
      variables: { limit, offset, searchParams },
      onCompleted: (searchData) => { setTotalObjects(searchData.digitalObjects.totalCount); },
    },
  );
  const history = useHistory();
  const location = useLocation();
  useEffect(
    () => {
      const parsedQueryString = qs.parse(location.search);
      const { q } = parsedQueryString;
      const queryPageNumber = Number.parseInt((parsedQueryString.pageNumber || '1'), 10);
      const filters = (parsedQueryString.filters)
        ? FilterArrayParam.decode(parsedQueryString.filters)
        : parsedQueryString.filters;
      const keywordChanged = !(q === searchParams.query);
      const filtersChanged = !(filters === searchParams.filters);
      const pageChanged = !(pageNumber === queryPageNumber);
      if (keywordChanged || filtersChanged || pageChanged) {
        setSearchParams({ query: q, filters });
        setOffset((queryPageNumber - 1) * limit);
        refetch();
      }
    },
    [location.search, history.location],
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);
  const { digitalObjects: { nodes, facets, totalCount } } = data;
  const onPageNumberClick = (page) => {
    const { filters = [] } = searchParams;
    const parsedQueryString = qs.parse(location.search);
    parsedQueryString.pageNumber = page;
    parsedQueryString.filters = FilterArrayParam.encode(filters);
    location.search = qs.stringify(parsedQueryString);
    history.push(location);
  };
  const isFacetCurrent = (fieldName, value) => {
    const detector = filter => ((filter.field === fieldName) && (filter.value === value));
    const { filters = [] } = searchParams;
    return filters ? filters.find(detector) : false;
  };
  const onFacetSelect = (fieldName, value) => {
    const detector = filter => ((filter.field === fieldName) && (filter.value === value));
    const others = filter => ((filter.field !== fieldName) || (filter.value !== value));
    const { filters = [] } = searchParams;
    const isFiltered = filters ? filters.find(detector) : false;
    const updatedFilters = isFiltered
      ? filters.filter(others)
      : [...filters, { field: fieldName, value }];
    const parsedQueryString = qs.parse(location.search);
    parsedQueryString.filters = FilterArrayParam.encode(updatedFilters);
    parsedQueryString.q = searchParams.query;
    // all changes should reset pageNumber to 1
    parsedQueryString.pageNumber = '1';
    location.search = qs.stringify(parsedQueryString);
    history.push(location);
  };
  const onQueryChange = (value) => {
    const { filters = [] } = searchParams;
    const parsedQueryString = qs.parse(location.search);
    parsedQueryString.q = value;
    parsedQueryString.filters = FilterArrayParam.encode(filters);
    // all changes should reset pageNumber to 1
    parsedQueryString.pageNumber = '1';
    location.search = qs.stringify(parsedQueryString);
    history.push(location);
  };
  const docsFound = nodes.length > 0;
  return (
    <>
      <ContextualNavbar
        title="Digital Objects"
        rightHandLinks={[{ label: 'New Digital Object', link: '/digital_objects/new' }]}
      />
      <>
        {
          docsFound && <ResultCountAndSortOptions totalCount={totalCount} limit={limit} offset={offset} searchParams={searchParams} />
        }
        <Row>
          <Col xs={9}>
            { docsFound
              ? <DigitalObjectList className="digital-object-search-results" digitalObjects={nodes} />
              : <Card><Card.Header>No Digital Objects found.</Card.Header></Card>
            }
          </Col>
          <Col xs={3}>
            <QueryForm value={query.q} onQueryChange={onQueryChange} onSubmit={refetch} />
            <DigitalObjectFacets className="digital-object-search-facets" facets={facets} isFacetCurrent={isFacetCurrent} onFacetSelect={onFacetSelect} />
          </Col>
        </Row>
      </>
      <PaginationBar
        offset={offset}
        limit={limit}
        totalItems={totalObjects}
        onPageNumberClick={onPageNumberClick}
      />
    </>
  );
};

export default withQueryParams(
  {
    q: StringParam,
    filters: FilterArrayParam,
    pageNumber: NumberParam,
  },
  DigitalObjectSearch,
);
