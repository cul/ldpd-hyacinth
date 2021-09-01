import gql from 'graphql-tag';

export const digitalObjectImportsQuery = gql`
  query DigitalObjectImports($id: ID!, $limit: Limit!, $offset: Offset!, $status: DigitalObjectImportStatusEnum){
    batchImport(id: $id) {
      id
      status
      originalFilename
      numberOfCreationFailureImports
      numberOfUpdateFailureImports
      numberOfPersistFailureImports
      numberOfPublishFailureImports
      numberOfInProgressImports
      numberOfPendingImports
      numberOfSuccessImports
      digitalObjectImports(limit: $limit, offset: $offset, status: $status) {
        totalCount
        nodes {
          id
          status
          index
          createdAt
          updatedAt
        }
      }
    }
  }
`;

export const digitalObjectImportQuery = gql`
  query DigitalObjectImports($batchImportId: ID!, $id: ID!){
    batchImport(id: $batchImportId) {
      id
      originalFilename
      digitalObjectImport(id: $id) {
        id
        status
        index
        importErrors
        digitalObjectData
        createdAt
        updatedAt
      }
    }
  }
`;
