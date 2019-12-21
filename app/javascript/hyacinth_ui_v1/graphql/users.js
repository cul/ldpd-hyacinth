import { gql } from 'apollo-boost';

export const getUsersQuery = gql`
  query Users {
    users {
      id,
      fullName
    }
  }
`;
