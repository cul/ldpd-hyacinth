import gql from 'graphql-tag';

export const getProjectsPublishTargetsQuery = gql`
  query($stringKey: ID!) {
    projectsPublishTargets(project: { stringKey: $stringKey }) {
      enabled
      stringKey
    }
  }
`;

export const updateProjectsPublishTargetsMutation = gql`
  mutation ($input: UpdateProjectPublishTargetsInput!) {
    updateProjectPublishTargets(input: $input) {
      projectPublishTargets {
        stringKey
      }
    }
  }
`;
