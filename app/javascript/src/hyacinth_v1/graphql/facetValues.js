import gql from 'graphql-tag';

export const facetValuesQuery = gql`
  query($fieldName: String!, $limit: Limit!, $offset: Offset = 0, $searchParams: SearchAttributes!, $orderBy: FacetOrderByInput!) {
    facetValues(fieldName: $fieldName, limit: $limit, offset: $offset, searchParams: $searchParams, orderBy: $orderBy) {
      nodes {
        value
        count
      },
      totalCount,
      pageInfo {
        hasNextPage,
        hasPreviousPage,
      },
    }
  }
`;

export default facetValuesQuery;
