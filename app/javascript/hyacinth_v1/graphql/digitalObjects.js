import gql from 'graphql-tag';

const minimalDigitalObjectProjectFields = `
  stringKey
`;

export const getMinimalDigitalObjectWithProjectsQuery = gql`
  query MinimalDigitalObject($id: ID!){
    digitalObject(id: $id) {
      id,
      digitalObjectType,
      primaryProject {
        ${minimalDigitalObjectProjectFields}
      },
      otherProjects {
        ${minimalDigitalObjectProjectFields}
      }
    }
  }
`;

const digitalObjectInterfaceFields = `
  id,
  state,
  digitalObjectType,
  title,
  numberOfChildren,
  doi,
  primaryProject {
    displayLabel,
    stringKey,
    hasAssetRights
  },
  otherProjects {
    displayLabel,
    stringKey
  }
`;

export const getSystemDataDigitalObjectQuery = gql`
  query SystemDataDigitalObject($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields},
      createdBy { fullName },
      createdAt,
      updatedBy { fullName },
      updatedAt,
      firstPublishedAt
    }
  }
`;

export const getMetadataDigitalObjectQuery = gql`
  query MetadataDigitalObject($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields},
      dynamicFieldData,
      identifiers
    }
  }
`;


export const getRightsDigitalObjectQuery = gql`
  query RightsDigitalObject($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields},
      dynamicFieldData
      rights
    }
  }
`;

export const getChildStructureQuery = gql`
  query ChildStructure($id: ID!){
    childStructure(id: $id) {
      parent {
        ${digitalObjectInterfaceFields},
      },
      type,
      structure {
        ${digitalObjectInterfaceFields},
      }
    }
  }
`;

export const getAssignmentsDigitalObjectQuery = gql`
  query AssignmentsDigitalObject($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields}
    }
  }
`;

export const getPreservePublishDigitalObjectQuery = gql`
  query PreservePublishDigitalObject($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields},
      publishEntries {
        publishTargetStringKey
      }
    }
  }
`;

export const getAssetDataDigitalObjectQuery = gql`
  query AssetDataDigitalObject($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields},
      resources {
        id
        displayLabel
        resource {
          location
          checksum
          originalFilePath
          originalFilename
          mediaType
          fileSize
        }
      },
      ... on Asset {
        assetType
      }
    }
  }
`;

export const getDigitalObjectsQuery = gql`
  query DigitalObjects($limit: Limit!, $offset: Offset = 0, $searchParams: SearchAttributes){
    digitalObjects(limit: $limit, offset: $offset, searchParams: $searchParams) {
      totalCount
      nodes {
        id,
        title,
        digitalObjectType
      },
      facets {
        fieldName,
        displayLabel,
        values {
          value,
          count
        }
      }
    }
  }
`;

export const updateRightsMutation = gql`
  mutation UpdateRights($input: UpdateRightsInput!) {
    updateRights(input: $input) {
      digitalObject {
        id
      }
    }
  }
`;
