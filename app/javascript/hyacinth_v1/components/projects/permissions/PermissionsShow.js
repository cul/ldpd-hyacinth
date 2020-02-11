import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import TabHeading from '../../ui/tabs/TabHeading';
import { Can } from '../../../util/ability_context';
import EditButton from '../../ui/buttons/EditButton';
import { getProjectWithPermissionsQuery } from '../../../graphql/projects';
import ProjectInterface from '../ProjectInterface';
import GraphQLErrors from '../../ui/GraphQLErrors';
import PermissionsEditor from './PermissionsEditor';

function PermissionsShow() {
  const { stringKey } = useParams();
  const { loading, error, data } = useQuery(getProjectWithPermissionsQuery, { variables: { stringKey } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>
        Permissions
        <Can I="update" of={{ subjectType: 'Project', stringKey: data.project.stringKey }}>
          <EditButton
            className="float-right"
            size="lg"
            link={`/projects/${data.project.stringKey}/permissions/edit`}
          />
        </Can>
      </TabHeading>

      <PermissionsEditor project={data.project} readOnly />
    </ProjectInterface>
  );
}

export default PermissionsShow;
