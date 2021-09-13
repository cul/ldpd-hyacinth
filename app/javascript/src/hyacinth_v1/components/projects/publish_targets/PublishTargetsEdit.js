import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import TabHeading from '../../shared/tabs/TabHeading';
import PublishTargetsForm from './PublishTargetsForm';
import { getAvailablePublishTargetsQuery } from '../../../graphql/projects/publishTargets';
import ProjectInterface from '../ProjectInterface';
import GraphQLErrors from '../../shared/GraphQLErrors';

function PublishTargetsEdit() {
  const { projectStringKey } = useParams();
  const { loading, error, data } = useQuery(getAvailablePublishTargetsQuery, { variables: { stringKey: projectStringKey } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { project } = data;

  return (
    <ProjectInterface project={project}>
      <TabHeading>Edit Enabled Publish Targets</TabHeading>
      <PublishTargetsForm
        project={project}
      />
    </ProjectInterface>
  );
}

export default PublishTargetsEdit;
