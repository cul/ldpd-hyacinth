/* eslint-disable import/prefer-default-export */
import gql from 'graphql-tag';

export const getPermissionActionsQuery = gql`
  query PermissionActions {
    permissionActions {
      projectActions
    }
  }
`;
