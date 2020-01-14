import { gql } from 'apollo-boost';
import { DirectUpload } from "activestorage"

export const createAssetMutation = gql`
  mutation CreateAsset($input: CreateAssetInput!) {
    createAsset(input: $input) {
      asset {
        id
      }
    }
  }
`;
