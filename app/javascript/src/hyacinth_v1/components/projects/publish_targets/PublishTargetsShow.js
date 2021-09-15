import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import TabHeading from '../../shared/tabs/TabHeading';
import PublishTargetsForm from './PublishTargetsForm';
import { Can } from '../../../utils/abilityContext';
import EditButton from '../../shared/buttons/EditButton';
import { getAvailablePublishTargetsQuery } from '../../../graphql/projects/publishTargets';
import ProjectInterface from '../ProjectInterface';
import GraphQLErrors from '../../shared/GraphQLErrors';

function PublishTargetsShow() {
  const { projectStringKey } = useParams();
  const { loading, error, data } = useQuery(getAvailablePublishTargetsQuery, { variables: { stringKey: projectStringKey } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { project } = data;

  return (
    <ProjectInterface project={project}>
      <TabHeading>
        Enabled Publish Targets
        <Can I="update" of={{ subjectType: 'Project', stringKey: project.stringKey }}>
          <EditButton
            className="float-end"
            size="lg"
            aria-label="Edit"
            link={`/projects/${project.stringKey}/publish_targets/edit`}
          />
        </Can>
      </TabHeading>

      <PublishTargetsForm
        readOnly
        project={project}
      />
    </ProjectInterface>
  );
}

export default PublishTargetsShow;
