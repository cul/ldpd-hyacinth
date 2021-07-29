import gql from 'graphql-tag';

// This query will return all the rights fields for a given form. Its nesting matches
// the maximum amount of nesting known for these fields.
export const rightsFieldsQuery = gql`
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
        isRepeatable
        children { # children can be dynamic fields or dynamic field groups
          type: __typename,
          ...on DynamicField {
            id
            fieldType
            displayLabel
            stringKey
            controlledVocabulary
            selectOptions
          }

          ...on DynamicFieldGroup {
            id
            stringKey
            displayLabel
            isRepeatable
            children {
              ...on DynamicField {
                type: __typename
                id
                fieldType
                displayLabel
                stringKey
                controlledVocabulary
                selectOptions
              }
            }
          }
        }
      }
    }
  }
`;
