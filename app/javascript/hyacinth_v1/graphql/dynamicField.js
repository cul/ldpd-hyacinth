import gql from 'graphql-tag';

export const getDynamicFieldQuery = gql`
  query DynamicField($id: ID!){
    dynamicField(id: $id) {
      id
      stringKey
      displayLabel
      sortOrder
      controlledVocabulary
      fieldType
      filterLabel
      isFacetable
      isIdentifierSearchable
      isKeywordSearchable
      isTitleSearchable
      selectOptions
    }
  }
`;

export const createDynamicFieldMutation = gql`
  mutation CreateDynamicField($input: CreateDynamicFieldInput!) {
    createDynamicField(input: $input) {
      dynamicField {
        id
      }
    }
  }
`;

export const updateDynamicFieldMutation = gql`
  mutation UpdateDynamicField($input: UpdateDynamicFieldInput!) {
    updateDynamicField(input: $input) {
      dynamicField {
        id
      }
    }
  }
`;

export const deleteDynamicFieldMutation = gql`
  mutation DeleteDynamicField($input: DeleteDynamicFieldInput!) {
    deleteDynamicField(input: $input) {
      dynamicField {
        id
      }
    }
  }
`;
