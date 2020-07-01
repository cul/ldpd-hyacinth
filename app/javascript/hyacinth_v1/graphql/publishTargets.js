import gql from 'graphql-tag';

export const publishTargetsQuery = gql`
  query PublishTargets($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
      publishTargets {
        type
        stringIdentifier
        publishUrl
        apiKey
      }
    }
  }
`;

export const publishTargetQuery = gql`
  query PublishTargets($projectStringKey: ID!, $type: PublishTargetTypeEnum!) {
    project(stringKey: $projectStringKey) {
      stringKey
      displayLabel
      publishTarget(type: $type) {
        stringIdentifier
        type
        publishUrl
        apiKey
        doiPriority
        isAllowedDoiTarget
      }
    }
  }
`;

export const createPublishTargetMutation = gql`
  mutation CreatePublishTarget($input: CreatePublishTargetInput!) {
    createPublishTarget(input: $input) {
      publishTarget {
        type
      }
    }
  }
`;

export const updatePublishTargetMutation = gql`
  mutation UpdatePublishTarget($input: UpdatePublishTargetInput!) {
    updatePublishTarget(input: $input) {
      publishTarget {
        type
      }
    }
  }
`;

export const deletePublishTargetMutation = gql`
  mutation DeletePublishTarget($input: DeletePublishTargetInput!) {
    deletePublishTarget(input: $input) {
      publishTarget {
        type
      }
    }
  }
`;
