import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectInterface from '../DigitalObjectInterface';
import DigitalObjectList from '../DigitalObjectList';
import TabHeading from '../../shared/tabs/TabHeading';
import { getParentsQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';

const Parents = (props) => {
  const { id } = props;
  const {
    loading: parentsLoading,
    error: parentsError,
    data: parentsData,
  } = useQuery(getParentsQuery, {
    variables: { id },
  });

  if (parentsLoading) return (<></>);
  if (parentsError) return (<GraphQLErrors errors={parentsError} />);

  const { digitalObject: { parents, ...digitalObject } } = parentsData;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>Parent Digital Objects</TabHeading>
      {/* We might want to create our own listing the adds remove buttons to all the parents. */}
      <DigitalObjectList digitalObjects={parents} />
      {/* TODO: Need to add the ability to add parents. */}
    </DigitalObjectInterface>
  );
};

export default Parents;

Parents.propTypes = {
  id: PropTypes.string.isRequired,
};
