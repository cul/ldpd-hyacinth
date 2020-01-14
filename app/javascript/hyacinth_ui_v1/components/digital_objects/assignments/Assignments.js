import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectInterface from '../NewDigitalObjectInterface';
import TabHeading from '../../ui/tabs/TabHeading';
import { getAssignmentsDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../ui/GraphQLErrors';

function Assignments(props) {
  const { id } = props;

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getAssignmentsDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>Assignments</TabHeading>
      <p>This feature is currently unavailable.</p>
    </DigitalObjectInterface>
  );
}

export default Assignments;

Assignments.propTypes = {
  id: PropTypes.string.isRequired,
};
