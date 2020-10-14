import React from 'react';
import { useHistory } from 'react-router-dom';
import { capitalize } from 'lodash';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';
import gql from 'graphql-tag';
import { decodeQueryParams } from 'use-query-params';

import Tab from '../shared/tabs/Tab';
import Tabs from '../shared/tabs/Tabs';
import TabBody from '../shared/tabs/TabBody';
import ContextualNavbar from '../shared/ContextualNavbar';
import ResultsPagingBar from '../shared/ResultsPagingBar';
import DigitalObjectSummary from './DigitalObjectSummary';
import { queryParamsConfig, encodeAndStringifySearch } from '../../utils/encodeAndStringifySearch';
import GraphQLErrors from '../shared/GraphQLErrors';


function DigitalObjectInterface(props) {
  const { digitalObject, children } = props;
  const { id, title, digitalObjectType } = digitalObject;
  const latestSearchQueryString = sessionStorage.getItem('searchQueryParams');
  const history = useHistory();
  const offset = sessionStorage.getItem('offset');
  const resultIndex = sessionStorage.getItem('resultIndex');

  const limit = 3;

  const queryParams = {
    q: undefined,
    pageNumber: undefined,
    perPage: undefined,
    filters: undefined,
    orderBy: undefined,
    ...JSON.parse(latestSearchQueryString),
  };

  const {
    q, filters, orderBy,
  } = decodeQueryParams(queryParamsConfig, queryParams);

  const searchParams = { query: q, filters };

  const getDigitalObjectIDQuery = gql`
  query DigitalObjects($limit: Limit!, $offset: Offset = 0, $searchParams: SearchAttributes, $orderBy: OrderByInput){
    digitalObjects(limit: $limit, offset: $offset, searchParams: $searchParams, orderBy: $orderBy) {
      totalCount
      nodes {
        id
      }
    }
  }
`;

  const {
    loading, error, data,
  } = useQuery(
    getDigitalObjectIDQuery, {
      variables: {
        limit,
        offset: Number(offset),
        searchParams,
        orderBy: { field: orderBy.split(' ')[0], direction: orderBy.split(' ')[1] },
      },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { digitalObjects: { totalCount, nodes } } = data;

  const backToSearchPath = () => {
    const latestSearchQuery = JSON.parse(latestSearchQueryString);
    // Delete a couple of search parameters that shouldn't appear in a user-facing search url
    delete latestSearchQuery.offset;
    delete latestSearchQuery.totalCount;
    const search = encodeAndStringifySearch(latestSearchQuery);
    return `/digital_objects?${search}`;
  };

  let rightHandLinksArray = [];

  if (latestSearchQueryString) {
    rightHandLinksArray = [{ link: backToSearchPath(), label: 'Back to Search' }];
  }

  const onResultClick = (offset, resultIndex, resultId) => {
    // handles special cases for first and second result
    let finalOffset = offset;
    if (offset === 1 && resultIndex === 2) {
      finalOffset = 0;
    } else if (offset < 0) {
      finalOffset = 0;
    }
    window.sessionStorage.setItem('offset', finalOffset);
    window.sessionStorage.setItem('resultIndex', resultIndex);
    history.push(`/digital_objects/${resultId}`);
  };

  return (
    <div className="digital-object-interface">
      <ContextualNavbar
        title={`${capitalize(digitalObjectType)}: ${title}`}
        rightHandLinks={rightHandLinksArray}
      />

      <DigitalObjectSummary digitalObject={digitalObject} />

      <Tabs>
        <Tab to={`/digital_objects/${id}/system_data`} name="System Data" />
        <Tab to={`/digital_objects/${id}/metadata`} name="Metadata" />
        <Tab to={`/digital_objects/${id}/rights`} name="Rights" />

        {
          (digitalObjectType === 'item') ? (
            <Tab to={`/digital_objects/${id}/children`} name="Manage Child Assets" />
          )
            : <></>
        }

        {
          (digitalObjectType === 'asset') ? (
            <>
              <Tab to={`/digital_objects/${id}/parents`} name="Parents" />
              <Tab to={`/digital_objects/${id}/asset_data`} name="Asset Data" />
            </>
          )
            : <></>
        }

        <Tab to={`/digital_objects/${id}/assignments`} name="Assignments" />
        <Tab to={`/digital_objects/${id}/preserve_publish`} name="Preserve/Publish" />
      </Tabs>

      <TabBody>
        {children}
      </TabBody>
      {
        // only show results paging if we came from a search and if there is more than one result
      (nodes.length > 1 && latestSearchQueryString != null) ? (
        <ResultsPagingBar
          totalCount={Number(totalCount)}
          offset={Number(offset)}
          nodes={nodes}
          uidCurrent={id}
          resultIndex={Number(resultIndex)}
          onResultClick={onResultClick}
        />
      ) : <></>
}
    </div>
  );
}

export default DigitalObjectInterface;

DigitalObjectInterface.propTypes = {
  digitalObject: PropTypes.objectOf(PropTypes.any).isRequired,
  children: PropTypes.node.isRequired,
};
