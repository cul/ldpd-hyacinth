import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import GraphQLErrors from '../shared/GraphQLErrors';
import PublishTargetForm from './PublishTargetForm';
import ContextualNavbar from '../shared/ContextualNavbar';
import { publishTargetQuery } from '../../graphql/publishTargets';

function PublishTargetEdit() {
  const { stringKey } = useParams();

  const { loading, error, data } = useQuery(publishTargetQuery, { variables: { stringKey } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <>
      <ContextualNavbar title="Edit Publish Target" />
      <PublishTargetForm formType="edit" publishTarget={data.publishTarget} />
    </>
  );
}

export default PublishTargetEdit;
