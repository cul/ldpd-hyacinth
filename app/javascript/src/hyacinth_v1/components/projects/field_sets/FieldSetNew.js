import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import TabHeading from '../../shared/tabs/TabHeading';
import FieldSetForm from './FieldSetForm';
import { getProjectQuery } from '../../../graphql/projects';
import ProjectInterface from '../ProjectInterface';
import GraphQLErrors from '../../shared/GraphQLErrors';

function FieldSetNew() {
  const { projectStringKey } = useParams();

  const { loading, error, data } = useQuery(
    getProjectQuery,
    { variables: { stringKey: projectStringKey } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>Create New Field Set</TabHeading>
      <FieldSetForm formType="new" projectStringKey={projectStringKey} />
    </ProjectInterface>
  );
}

export default FieldSetNew;
