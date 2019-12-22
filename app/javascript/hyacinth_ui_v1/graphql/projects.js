import { gql } from 'apollo-boost';

export const getProjectQuery = gql`
  query Project($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
      isPrimary
      projectUrl
    }
  }
`;

export const updateProjectMutation = gql`
  mutation UpdateProject($input: UpdateProjectInput!) {
    updateProject(input: $input) {
      project {
        stringKey
      }
    }
  }
`;

export const deleteProjectMutation = gql`
  mutation DeleteProject($input: DeleteProjectInput!) {
    deleteProject(input: $input) {
      project {
        stringKey
      }
    }
  }
`;

export const getProjectPermissionActionsQuery = gql`
  query ProjectPermissionActions {
    projectPermissionActions
  }
`;

// TODO: Eventually request users ordered by name
export const getProjectPermissionsQuery = gql`
  query ProjectPermissions($stringKey: String!){
    projectPermissionsForProject(stringKey: $stringKey) {
      user {
        id,
        fullName
      },
      project {
        stringKey
        displayLabel
      },
      permissions
    }
  }
`;

export const updateProjectPermissionsMutation = gql`
  mutation UpdateProjectPermissions($input: UpdateProjectPermissionsInput!) {
    updateProjectPermissions(input: $input) {
      errors
    }
  }
`;
