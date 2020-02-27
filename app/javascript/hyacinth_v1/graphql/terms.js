import gql from 'graphql-tag';

export const getTermsQuery = gql`
  query Terms($vocabularyStringKey: ID!, $limit: Limit!, $offset: Offset, $searchParams: SearchAttributes) {
    vocabulary(stringKey: $vocabularyStringKey) {
      stringKey
      label
      locked
      customFieldDefinitions {
        fieldKey
        label
        dataType
      }
      terms(limit: $limit, offset: $offset, searchParams: $searchParams) {
        totalCount
        nodes {
          id
          uri
          prefLabel
          altLabels
          authority
          termType
          customFields {
            field
            value
          }
        }
      }
    }
  }
`;


export const getTermQuery = gql`
  query Term($vocabularyStringKey: ID!, $uri: ID!) {
    vocabulary(stringKey: $vocabularyStringKey) {
      stringKey
      label
      locked
      customFieldDefinitions {
        fieldKey
        label
        dataType
      }
      term(uri: $uri) {
        id
        uri
        prefLabel
        altLabels
        authority
        termType
        customFields {
          field
          value
        }
      }
    }
  }
`;

export const createTermMutation = gql`
  mutation CreateTerm($input: CreateTermInput!) {
    createTerm(input: $input) {
      term {
        id
        uri
        prefLabel
        termType
      }
    }
  }
`;

export const updateTermMutation = gql`
  mutation UpdateTerm($input: UpdateTermInput!) {
    updateTerm(input: $input) {
      term {
        uri
      }
    }
  }
`;

export const deleteTermMutation = gql`
  mutation DeleteTerm($input: DeleteTermInput!) {
    deleteTerm(input: $input) {
      term {
        uri
      }
    }
  }
`;
