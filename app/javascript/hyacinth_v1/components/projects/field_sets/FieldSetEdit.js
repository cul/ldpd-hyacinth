import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';
import { gql } from 'apollo-boost';

import ProjectInterface from '../ProjectInterface';
import TabHeading from '../../ui/tabs/TabHeading';
import FieldSetForm from './FieldSetForm';
import GraphQLErrors from '../../ui/GraphQLErrors';

const getFieldSet = gql`
  query FieldSet($stringKey: ID!, $id: ID!) {
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
      fieldSet(id: $id) {
        id
        displayLabel
      }
    }
  }
`;

function FieldSetEdit() {
  const { projectStringKey, id } = useParams();

  const { loading, error, data } = useQuery(
    getFieldSet,
    { variables: { stringKey: projectStringKey, id } },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  return (
    <ProjectInterface project={data.project}>
      <TabHeading>Edit Field Set</TabHeading>
      <FieldSetForm formType="edit" projectStringKey={projectStringKey} key={id} fieldSet={data.project.fieldSet} />
    </ProjectInterface>
  );
}

export default FieldSetEdit;
