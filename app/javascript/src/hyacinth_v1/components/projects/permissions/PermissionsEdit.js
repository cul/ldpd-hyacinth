import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import TabHeading from '../../shared/tabs/TabHeading';
import ProjectInterface from '../ProjectInterface';
import { getProjectWithPermissionsQuery } from '../../../graphql/projects';
import GraphQLErrors from '../../shared/GraphQLErrors';
import PermissionsEditor from './PermissionsEditor';

function PermissionsEdit() {
  const { stringKey } = useParams();
  const { loading, error, data } = useQuery(getProjectWithPermissionsQuery, { variables: { stringKey } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>
        Permissions
      </TabHeading>

      <PermissionsEditor project={data.project} />
    </ProjectInterface>
  );
}

export default PermissionsEdit;
