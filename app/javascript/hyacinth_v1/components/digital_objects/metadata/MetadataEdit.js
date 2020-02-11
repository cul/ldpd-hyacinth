import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/react-hooks';

import MetadataTab from './MetadataTab';
import MetadataForm from './MetadataForm';
import { getMetadataDigitalObjectQuery } from '../../../graphql/digitalObjects';
import GraphQLErrors from '../../ui/GraphQLErrors';

function MetadataEdit(props) {
  const { id } = props;

  const {
    loading: digitalObjectLoading,
    error: digitalObjectError,
    data: digitalObjectData,
  } = useQuery(getMetadataDigitalObjectQuery, {
    variables: { id },
  });

  if (digitalObjectLoading) return (<></>);
  if (digitalObjectError) return (<GraphQLErrors errors={digitalObjectError} />);
  const { digitalObject } = digitalObjectData;

  return (
    <MetadataTab digitalObject={digitalObject}>
      <MetadataForm formType="edit" digitalObject={digitalObject} />
    </MetadataTab>
  );
}

export default MetadataEdit;

MetadataEdit.propTypes = {
  id: PropTypes.string.isRequired,
};
