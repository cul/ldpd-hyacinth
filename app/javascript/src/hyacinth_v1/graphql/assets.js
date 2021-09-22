/* eslint-disable import/prefer-default-export */
import gql from 'graphql-tag';

export const createAssetMutation = gql`
  mutation CreateAsset($input: CreateAssetInput!) {
    createAsset(input: $input) {
      asset {
        id
      }
    }
  }
`;
