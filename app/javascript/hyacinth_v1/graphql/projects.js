import gql from 'graphql-tag';

export const getProjectQuery = gql`
  query Project($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
      isPrimary
      hasAssetRights
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

const getProjectsFields = `
  stringKey
  displayLabel
  isPrimary
  hasAssetRights
  projectUrl,
  enabledDigitalObjectTypes
`;

export const getProjectsQuery = gql`
  query {
    projects {
      ${getProjectsFields}
    }
  }
`;

export const getPrimaryProjectsQuery = gql`
  query {
    projects(isPrimary: true) {
      ${getProjectsFields}
    }
  }
`;

const projectPermissionsFields = `
  user {
    id,
    fullName,
    sortName
  },
  project {
    stringKey
    displayLabel
    isPrimary
  },
  actions
`;

export const getProjectWithPermissionsQuery = gql`
  query ProjectWithPermissions($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
      isPrimary
      projectPermissions {
        ${projectPermissionsFields}
      }
    }
  }
`;

export const updateProjectPermissionsMutation = gql`
  mutation UpdateProjectPermissions($input: UpdateProjectPermissionsInput!) {
    updateProjectPermissions(input: $input) {
      projectPermissions {
        ${projectPermissionsFields}
      }
    }
  }
`;
