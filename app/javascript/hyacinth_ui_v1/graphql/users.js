import { gql } from 'apollo-boost';

export const GetUsersQuery = gql`
  query {
    users {
      id
      firstName
      lastName
      email
      isActive
    }
  }
`;

export const GetUserQuery = gql`
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

export const CreateUserMutation = gql`
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      user {
        id
      }
    }
  }
`;

export const UpdateUserMutation = gql`
  mutation UpdateUser($input: UpdateUserInput!){
    updateUser(input: $input){
      user {
        id
      }
    }
  }
`;
