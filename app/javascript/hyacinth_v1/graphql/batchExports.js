import gql from 'graphql-tag';

export const batchExportsQuery = gql`
  query BatchExports($limit: Limit!, $offset: Offset = 0){
    batchExports(limit: $limit, offset: $offset) {
      nodes {
        id
        searchParams
        user {
          fullName
        }
        createdAt,
        status
        numberOfRecordsProcessed
      }
      pageInfo {
        hasPreviousPage
        hasNextPage
      }
      totalCount
    }
  }
`;

export const createBatchExportMutation = gql`
  mutation CreateBatchExport($input: CreateBatchExportInput!) {
    createBatchExport(input: $input) {
      batchExport {
        id
      }
    }
  }
`;

export const deleteBatchExportMutation = gql`
  mutation DeleteBatchExport($input: DeleteBatchExportInput!) {
    deleteBatchExport(input: $input) {
      batchExport {
        id
      }
    }
  }
`;
