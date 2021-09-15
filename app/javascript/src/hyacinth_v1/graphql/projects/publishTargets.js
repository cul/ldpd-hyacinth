import gql from 'graphql-tag';

export const getAvailablePublishTargetsQuery = gql`
  query Project($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
      availablePublishTargets {
        enabled
        stringKey
      }
    }
  }
`;

export const updateProjectsPublishTargetsMutation = gql`
  mutation ($input: UpdateProjectPublishTargetsInput!) {
    updateProjectPublishTargets(input: $input) {
      enabledPublishTargets {
        stringKey
      }
    }
  }
`;
