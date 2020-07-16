import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import GraphQLErrors from '../../shared/GraphQLErrors';
import TabHeading from '../../shared/tabs/TabHeading';
import PublishTargetForm from './PublishTargetForm';
import ProjectInterface from '../ProjectInterface';
import { publishTargetQuery } from '../../../graphql/publishTargets';

function PublishTargetEdit() {
  const { projectStringKey, type } = useParams();

  const { loading, error, data } = useQuery(
    publishTargetQuery,
    { variables: { projectStringKey, type: type.toUpperCase() } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>Edit Publish Target</TabHeading>
      <PublishTargetForm formType="edit" projectStringKey={projectStringKey} publishTarget={data.project.publishTarget} stringKey={data.project.publishTarget.stringKey} />
    </ProjectInterface>
  );
}

export default PublishTargetEdit;
