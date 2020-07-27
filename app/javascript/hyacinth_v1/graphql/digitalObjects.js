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
      descriptiveMetadata,
      identifiers
    }
  }
`;


export const getRightsDigitalObjectQuery = gql`
  query RightsDigitalObject($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields},
      descriptiveMetadata
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

export const getParentsQuery = gql`
  query DigitalObjectParents($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields},
      parents {
        id
        title
        digitalObjectType
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
  query DigitalObjects($limit: Limit!, $offset: Offset = 0, $searchParams: SearchAttributes, $orderBy: OrderByInput){
    digitalObjects(limit: $limit, offset: $offset, searchParams: $searchParams, orderBy: $orderBy) {
      totalCount
      nodes {
        id,
        title,
        digitalObjectType,
        numberOfChildren,
        parentIds,
        projects {
          stringKey
          displayLabel
        }
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

export const createDigitalObjectMutation = gql`
  mutation CreateDigitalObject($input: CreateDigitalObjectInput!) {
    createDigitalObject(input: $input) {
      digitalObject {
        id
      }
    }
  }
`;

export const updateDescriptiveMetadataMutation = gql`
  mutation UpdateDescriptiveMetadata($input: UpdateDescriptiveMetadataInput!) {
    updateDescriptiveMetadata(input: $input) {
      digitalObject {
        id
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
