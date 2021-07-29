import gql from 'graphql-tag';

export const getUsersQuery = gql`
  query Users {
    users {
      id
      firstName
      lastName
      fullName
      sortName
      email
      isActive
    }
  }
`;

export const getUserQuery = gql`
  query User($id: ID!){
    user(id: $id) {
      id
      firstName
      lastName
      email
      isActive
      isAdmin
      permissions
    }
  }
`;

export const createUserMutation = gql`
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      user {
        id
      }
    }
  }
`;

export const updateUserMutation = gql`
  mutation UpdateUser($input: UpdateUserInput!){
    updateUser(input: $input){
      user {
        id
      }
    }
  }
`;

export const getAuthenticatedUserQuery = gql`
  query AuthenticatedUser {
    authenticatedUser {
      id
      firstName
      lastName
      isAdmin
      rules {
        actions
        subject
        conditions
        inverted
      }
    }
  }
`;
