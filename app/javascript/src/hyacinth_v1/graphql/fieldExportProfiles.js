import gql from 'graphql-tag';

export const fieldExportProfilesQuery = gql`
  query FieldExportProfiles {
    fieldExportProfiles {
      id
      name
      translationLogic
    }
  }
`;

export const fieldExportProfileQuery = gql`
  query FieldExportProfile($id: ID!) {
    fieldExportProfile(id: $id) {
      id
      name
      translationLogic
    }
  }
`;

export const createFieldExportProfileMutation = gql`
  mutation CreateFieldExportProfile($input: CreateFieldExportProfileInput!) {
    createFieldExportProfile(input: $input) {
      fieldExportProfile {
        id
      }
    }
  }
`;

export const updateFieldExportProfileMutation = gql`
  mutation UpdateFieldExportProfile($input: UpdateFieldExportProfileInput!) {
    updateFieldExportProfile(input: $input) {
      fieldExportProfile {
        id
      }
    }
  }
`;

export const deleteFieldExportProfileMutation = gql`
  mutation DeleteFieldExportProfile($input: DeleteFieldExportProfileInput!) {
    deleteFieldExportProfile(input: $input) {
      fieldExportProfile {
        id
      }
    }
  }
`;
