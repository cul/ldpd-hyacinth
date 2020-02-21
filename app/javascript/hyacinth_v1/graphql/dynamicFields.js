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

export const dynamicFieldPathQuery = gql`
  query DynamicFieldPathQuery($id: ID!) {
    dynamicField(id: $id) {
      id
      displayLabel
      type: __typename
      __typename # Apollo can't correctly cache if we override this field. Eventually we might override how cache identifiers are generated.
      path {
        ...on DynamicFieldGroup {
          id
          displayLabel
        }
        ...on DynamicFieldCategory {
          id
          displayLabel
        }
        type: __typename
        __typename
      }
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
