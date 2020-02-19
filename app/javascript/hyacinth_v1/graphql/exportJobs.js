import gql from 'graphql-tag';

export const exportJobsQuery = gql`
  query ExportJobs($limit: Limit!, $offset: Offset = 0){
    exportJobs(limit: $limit, offset: $offset) {
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
