import gql from 'graphql-tag';

export const getDynamicFieldGroupQuery = gql`
  query DynamicFieldGroup($id: ID!){
    dynamicFieldGroup(id: $id) {
      id
      stringKey
      displayLabel
      sortOrder
      exportRules {
        id
        fieldExportProfile {
          id
          name
        }
        translationLogic
      }
      isRepeatable
      parent {
        type: __typename
        ...on DynamicFieldGroup { id }
        ...on DynamicFieldCategory { id }
      }
    }
  }
`;

export const dynamicFieldGroupChildrenQuery = gql`
  query DynamicFieldGroupChildren($id: ID!) {
    dynamicFieldGroup(id: $id) {
      id
      children {
        type: __typename
        ...on DynamicFieldGroup {
          id
          stringKey
          displayLabel
          sortOrder

        }
        ...on DynamicField {
          id
          stringKey
          displayLabel
          sortOrder
        }
      }
    }
  }
`;

export const dynamicFieldGroupPathQuery = gql`
  query DynamicFieldGroupPathQuery($id: ID!) {
    dynamicFieldGroup(id: $id) {
      id
      displayLabel
      type: __typename
      __typename # Apollo can't correctly cache if we override this field. Maybe later: override how cache identifiers are generated.
      ancestorNodes {
        ...on DynamicFieldGroup {
          id
          displayLabel
        }
        ...on DynamicFieldCategory {
          id
          displayLabel
        }
        type: __typename
      }
    }
  }
`;

export const createDynamicFieldGroupMutation = gql`
  mutation CreateDynamicFieldGroup($input: CreateDynamicFieldGroupInput!) {
    createDynamicFieldGroup(input: $input) {
      dynamicFieldGroup {
        id
      }
    }
  }
`;

export const updateDynamicFieldGroupMutation = gql`
  mutation UpdateDynamicFieldGroup($input: UpdateDynamicFieldGroupInput!) {
    updateDynamicFieldGroup(input: $input) {
      dynamicFieldGroup {
        id
      }
    }
  }
`;

export const deleteDynamicFieldGroupMutation = gql`
  mutation DeleteDynamicFieldGroup($input: DeleteDynamicFieldGroupInput!) {
    deleteDynamicFieldGroup(input: $input) {
      dynamicFieldGroup {
        id
      }
    }
  }
`;
