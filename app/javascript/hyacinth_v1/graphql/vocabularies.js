import { gql } from 'apollo-boost';

export const getVocabulariesQuery = gql`
  query Vocabularies($limit: Limit!, $offset: Offset = 0){
    vocabularies(limit: $limit, offset: $offset) {
      totalCount
      nodes {
        stringKey
        label
      }
    }
  }
`;

export const getVocabularyQuery = gql`
  query Vocabulary($stringKey: ID!) {
    vocabulary(stringKey: $stringKey) {
      stringKey
      label
      locked
      customFieldDefinitions {
        fieldKey
        label
        dataType
      }
    }
  }
`;

export const createVocabularyMutation = gql`
  mutation CreateVocabulary($input: CreateVocabularyInput!) {
    createVocabulary(input: $input) {
      vocabulary {
        stringKey
      }
    }
  }
`;

export const updateVocabularyMutation = gql`
  mutation UpdateVocabulary($input: UpdateVocabularyInput!) {
    updateVocabulary(input: $input) {
      vocabulary {
        stringKey
      }
    }
  }
`;

export const deleteVocabularyMutation = gql`
  mutation DeleteVocabulary($input: DeleteVocabularyInput!) {
    deleteVocabulary(input: $input) {
      vocabulary {
        stringKey
      }
    }
  }
`;
