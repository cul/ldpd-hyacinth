import gql from 'graphql-tag';

export const getDynamicFieldCategoryQuery = gql`
  query DynamicFieldCategory($id: ID!){
    dynamicFieldCategory(id: $id) {
      id
      displayLabel
      sortOrder
      type: __typename
    }
  }
`;

export const getDynamicFieldCategoriesQuery = gql`
  query DynamicFieldCategories($metadataForm: MetadataFormEnum) {
     dynamicFieldCategories(metadataForm: $metadataForm) {
      id
      displayLabel
      sortOrder
      children { # all children will always be dynamicFieldGroups
        type: __typename
        id
        stringKey
        displayLabel
        sortOrder
      }
    }
  }
`;

export const createDynamicFieldCategoryMutation = gql`
  mutation CreateDynamicFieldCategory($input: CreateDynamicFieldCategoryInput!) {
    createDynamicFieldCategory(input: $input) {
      dynamicFieldCategory {
        id
      }
    }
  }
`;

export const updateDynamicFieldCategoryMutation = gql`
  mutation UpdateDynamicFieldCategory($input: UpdateDynamicFieldCategoryInput!) {
    updateDynamicFieldCategory(input: $input) {
      dynamicFieldCategory {
        id
      }
    }
  }
`;

export const deleteDynamicFieldCategoryMutation = gql`
  mutation DeleteDynamicFieldCategory($input: DeleteDynamicFieldCategoryInput!) {
    deleteDynamicFieldCategory(input: $input) {
      dynamicFieldCategory {
        id
      }
    }
  }
`;
