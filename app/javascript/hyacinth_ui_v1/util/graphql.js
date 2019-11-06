import { gql } from 'apollo-boost';

export const getProject = gql`
  query Project($stringKey: ID!){
    project(stringKey: $stringKey) {
      stringKey
      displayLabel
      projectUrl
    }
  }
`;
