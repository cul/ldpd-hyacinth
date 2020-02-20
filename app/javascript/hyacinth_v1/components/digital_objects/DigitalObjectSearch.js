import React, { useState } from 'react';
import { Card, Col, Row } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectList from './DigitalObjectList';
import DigitalObjectFacets from './DigitalObjectFacets';
import ResultCountAndSortOptions from './search/ResultCountAndSortOptions';

import ContextualNavbar from '../shared/ContextualNavbar';
import PaginationBar from '../shared/PaginationBar';
import GraphQLErrors from '../shared/GraphQLErrors';
import { getDigitalObjectsQuery } from '../../graphql/digitalObjects';

const limit = 20;

export default function DigitalObjectSearch() {
  const [offset, setOffset] = useState(0);
  const [totalObjects, setTotalObjects] = useState(0);
  const filtersState = useState([]);
  const [filters, setFilters] = filtersState;
  const [query, setQuery] = useState();

  const {
    loading, error, data, refetch,
  } = useQuery(
    getDigitalObjectsQuery, {
      variables: { limit, offset, filters, query },
      onCompleted: (searchData) => { setTotalObjects(searchData.digitalObjects.totalCount); },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);
  const { digitalObjects: { nodes, facets, totalCount } } = data;
  const onPageNumberClick = (page) => {
    setOffset(limit * (page - 1));
    refetch();
  };
  const isFacetCurrent = (fieldName, value) => {
    const detector = filter => ((filter.field === fieldName) && (filter.value === value));
    return filters.find(detector);
  };
  const onFacetSelect = (fieldName, value) => {
    const detector = filter => ((filter.field === fieldName) && (filter.value === value));
    const others = filter => ((filter.field !== fieldName) || (filter.value !== value));
    const isFiltered = filters.find(detector);
    if (isFiltered) {
      setFilters(filters.filter(others));
    } else {
      setFilters([...filters, { field: fieldName, value }]);
    }
    refetch();
  };
  return (
    <>
      <ContextualNavbar
        title="Digital Objects"
        rightHandLinks={[{ label: 'New Digital Object', link: '/digital_objects/new' }]}
      />
      { nodes.length === 0 ? <Card header="No Digital Objects found." />
        : (
          <>
            <ResultCountAndSortOptions totalCount={totalCount} limit={limit} offset={offset} searchParams={{}} />
            <Row>
              <Col xs={10}>
                <DigitalObjectList className="digital-object-search-results" digitalObjects={nodes} />
              </Col>
              <Col xs={2}>
                <DigitalObjectFacets className="digital-object-search-facets" facets={facets} isFacetCurrent={isFacetCurrent} onFacetSelect={onFacetSelect} />
              </Col>
            </Row>
          </>
        )
      }
      <PaginationBar
        offset={offset}
        limit={limit}
        totalItems={totalObjects}
        onPageNumberClick={onPageNumberClick}
      />
    </>
  );
}
