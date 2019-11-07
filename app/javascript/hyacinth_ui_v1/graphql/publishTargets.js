import { gql } from 'apollo-boost';

export const createPublishTargetMutation = gql`
  mutation CreatePublishTarget($input: CreatePublishTargetInput!) {
    createPublishTarget(input: $input) {
      publishTarget {
        stringKey
      }
    }
  }
`;

export const updatePublishTargetMutation = gql`
  mutation UpdatePublishTarget($input: UpdatePublishTargetInput!) {
    updatePublishTarget(input: $input) {
      publishTarget {
        stringKey
      }
    }
  }
`;

export const deletePublishTargetMutation = gql`
  mutation DeletePublishTarget($input: DeletePublishTargetInput!) {
    deletePublishTarget(input: $input) {
      publishTarget {
        stringKey
      }
    }
  }
`;
