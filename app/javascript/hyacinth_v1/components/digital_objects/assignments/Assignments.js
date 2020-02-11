import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../shared/tabs/TabHeading';
import { getAssignmentsDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../shared/GraphQLErrors';

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

Assignments.propTypes = {
  id: PropTypes.string.isRequired,
};

export default Assignments;
