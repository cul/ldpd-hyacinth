import gql from 'graphql-tag';

export const publishTargetsQuery = gql`
  query PublishTargets {
    publishTargets {
      stringKey
      publishUrl
      apiKey
      doiPriority
      isAllowedDoiTarget
    }
  }
`;

export const publishTargetQuery = gql`
  query PublishTargets($stringKey: ID!) {
    publishTarget(stringKey: $stringKey) {
      stringKey
      publishUrl
      apiKey
      doiPriority
      isAllowedDoiTarget
    }
  }
`;

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
