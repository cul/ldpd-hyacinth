import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import TabHeading from '../../ui/tabs/TabHeading';
import PublishTargetForm from './PublishTargetForm';
import ProjectInterface from '../ProjectInterface';
import { getProject } from '../../../util/graphql';
import GraphQLErrors from '../../ui/GraphQLErrors';

function PublishTargetNew() {
  const { projectStringKey } = useParams();
  const { loading, error, data } = useQuery(
    getProject,
    { variables: { stringKey: projectStringKey } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>Create New Publish Target</TabHeading>
      <PublishTargetForm formType="new" projectStringKey={projectStringKey} />
    </ProjectInterface>
  );
}

export default PublishTargetNew;
