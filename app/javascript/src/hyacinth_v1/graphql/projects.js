import gql from 'graphql-tag';

export const getProjectQuery = gql`
  query Project($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
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

const projectPermissionsFields = `
  user {
    id,
    fullName,
    sortName
  },
  project {
    stringKey
    displayLabel
  },
  actions
`;

export const getProjectWithPermissionsQuery = gql`
  query ProjectWithPermissions($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
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
