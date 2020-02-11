import gql from 'graphql-tag';

export const getPermissionActionsQuery = gql`
  query PermissionActions {
    permissionActions {
      projectActions,
      primaryProjectActions,
      aggregatorProjectActions
    }
  }
`;
