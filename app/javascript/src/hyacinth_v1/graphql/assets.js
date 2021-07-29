import gql from 'graphql-tag';
import { DirectUpload } from '@rails/activestorage';

export const createAssetMutation = gql`
  mutation CreateAsset($input: CreateAssetInput!) {
    createAsset(input: $input) {
      asset {
        id
      }
    }
  }
`;
