import gql from 'graphql-tag';

export const batchImportsQuery = gql`
  query BatchImports($limit: Limit!, $offset: Offset = 0){
    batchImports(limit: $limit, offset: $offset) {
      nodes {
        id
        user {
          fullName
        }
        numberOfFailureImports
        numberOfInProgressImports
        numberOfPendingImports
        numberOfSuccessImports
        priority
        originalFilename
        createdAt
        status
        cancelled
        setupErrors
      }
      totalCount
    }
  }
`;

export const batchImportQuery = gql`
  query BatchImport($id: ID!){
    batchImport(id: $id) {
      id
      user {
        fullName
        email
      }
      numberOfFailureImports
      numberOfInProgressImports
      numberOfPendingImports
      numberOfSuccessImports
      priority
      downloadPath
      withoutSuccessfulImportsDownloadPath
      originalFilename
      fileLocation
      createdAt
      status
      cancelled
      setupErrors
    }
  }
`;

export const createBatchImportMutation = gql`
  mutation CreateBatchImport($input: CreateBatchImportInput!) {
    createBatchImport(input: $input) {
      batchImport {
        id
      }
      isValid
      errors
    }
  }
`;

export const validateBatchImportMutation = gql`
  mutation ValidateBatchImport($input: ValidateBatchImportInput!) {
    validateBatchImport(input: $input) {
      isValid
      errors
    }
  }
`;

export const updateBatchImportMutation = gql`
  mutation UpdateBatchImport($input: UpdateBatchImportInput!) {
    updateBatchImport(input: $input) {
      batchImport {
        id
      }
    }
  }
`;

export const deleteBatchImportMutation = gql`
  mutation DeleteBatchImport($input: DeleteBatchImportInput!) {
    deleteBatchImport(input: $input) {
      batchImport {
        id
      }
    }
  }
`;

export const startBatchImportMutation = gql`
  mutation StartBatchImport($input: StartBatchImportInput!) {
    startBatchImport(input: $input) {
      batchImport {
        id
      }
    }
  }
`;
