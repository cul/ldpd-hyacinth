import { gql } from 'apollo-boost';

export const getPermissionActionsQuery = gql`
  query PermissionActions {
    permissionActions {
      projectActions,
      primaryProjectActions,
      aggregatorProjectActions
    }
  }
`;

