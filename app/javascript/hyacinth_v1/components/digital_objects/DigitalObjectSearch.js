import React, { useState } from 'react';
import { Card } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectList from './DigitalObjectList';

import ContextualNavbar from '../layout/ContextualNavbar';
import PaginationBar from '../ui/PaginationBar';
import GraphQLErrors from '../ui/GraphQLErrors';
import { getDigitalObjectsQuery } from '../../graphql/digitalObjects';

const limit = 20;

export default function DigitalObjectSearch() {
  const [offset, setOffset] = useState(0);
  const [totalObjects, setTotalObjects] = useState(0);

  const {
    loading, error, data, refetch,
  } = useQuery(
    getDigitalObjectsQuery, {
      variables: { limit, offset },
      onCompleted: (searchData) => { setTotalObjects(searchData.digitalObjects.totalCount); },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);
  const { digitalObjects: { nodes } } = data;
  const onPageNumberClick = (page) => {
    setOffset(limit * (page - 1));
    refetch();
  };

  return (
    <>
      <ContextualNavbar
        title="Digital Objects"
        rightHandLinks={[{ label: 'New Digital Object', link: '/digital_objects/new' }]}
      />
      { nodes.length === 0 ? <Card header="No Digital Objects found." />
        : <DigitalObjectList className="digital-object-search-results" digitalObjects={nodes} />
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
