import React from 'react';
import gql from 'graphql-tag';
import { useQuery } from '@apollo/react-hooks';
import { useParams } from 'react-router-dom';

import GraphQLErrors from '../../shared/GraphQLErrors';
import TabHeading from '../../shared/tabs/TabHeading';
import PublishTargetForm from './PublishTargetForm';
import ProjectInterface from '../ProjectInterface';

const getPublishTarget = gql`
  query FieldSet($projectStringKey: ID!, $stringKey: ID!) {
    project(stringKey: $projectStringKey) {
      stringKey
      displayLabel
      publishTarget(stringKey: $stringKey) {
        stringKey
        displayLabel
        publishUrl
        apiKey
        doiPriority
        isAllowedDoiTarget
      }
    }
  }
`;

function PublishTargetEdit() {
  const { projectStringKey, stringKey } = useParams();

  const { loading, error, data } = useQuery(
    getPublishTarget,
    { variables: { projectStringKey, stringKey } },
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
