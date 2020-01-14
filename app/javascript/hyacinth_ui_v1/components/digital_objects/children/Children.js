import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import DigitalObjectInterface from '../DigitalObjectInterface';
import TabHeading from '../../ui/tabs/TabHeading';
import { getChildrenDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../ui/GraphQLErrors';

function Children(props) {
  const { id } = props;

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getChildrenDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  return (
    <DigitalObjectInterface digitalObject={digitalObject}>
      <TabHeading>Manage Child Assets</TabHeading>
      <p>This feature is currently unavailable.</p>
    </DigitalObjectInterface>
  );
}

export default Children;

Children.propTypes = {
  id: PropTypes.string.isRequired,
};
