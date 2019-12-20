import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import TabHeading from '../../ui/tabs/TabHeading';
import ProjectInterface from '../ProjectInterface';
import { getProjectQuery } from '../../../graphql/projects';
import GraphQLErrors from '../../ui/GraphQLErrors';
import PermissionsEditor from './PermissionsEditor';

function PermissionsEdit() {
  const { stringKey } = useParams();
  const { loading, error, data } = useQuery(getProjectQuery, { variables: { stringKey } });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>
        Permissions
      </TabHeading>

      <PermissionsEditor projectStringKey={data.project.stringKey} />
    </ProjectInterface>
  );
}

export default PermissionsEdit;
