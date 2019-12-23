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

export const createProjectMutation = gql`
  mutation CreateProject($input: CreateProjectInput!) {
    createProject(input: $input) {
      project {
        stringKey
        isPrimary
      }
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

export const getProjectsQuery = gql`
  query {
    projects {
      stringKey
      displayLabel
      isPrimary
      projectUrl
    }
  }
`;

export const getProjectPermissionActionsQuery = gql`
  query ProjectPermissionActions {
    projectPermissionActions {
      actions,
      readObjectsAction,
      manageAction
    }
  }
`;

export const getProjectPermissionsQuery = gql`
  query ProjectPermissions($stringKey: String!){
    projectPermissionsForProject(stringKey: $stringKey) {
      user {
        id,
        fullName,
        sortName
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
