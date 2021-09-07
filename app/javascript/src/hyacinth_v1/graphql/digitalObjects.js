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
  displayLabel,
  title {
    value {
      nonSortPortion,
      sortPortion,
    },
    valueLang {
      tag,
    }
    subtitle,
  },
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

const digitalObjectResourcesFields = `
  resources {
    id
    displayLabel
    uiDeletable
    resource {
      location
      checksum
      originalFilePath
      originalFilename
      mediaType
      fileSize
    }
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
      optimisticLockToken,
      descriptiveMetadata,
      identifiers
    }
  }
`;

export const getRightsDigitalObjectQuery = gql`
  query RightsDigitalObject($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields},
      optimisticLockToken,
      descriptiveMetadata,
      rights
    }
  }
`;

export const getChildStructureDigtialObjectQuery = gql`
  query DigitalObjectChildStructure($id: ID!){
    digitalObject(id: $id) {
      ${digitalObjectInterfaceFields},
      childStructure {
        type
        structure {
          id
          displayLabel
          digitalObjectType
        }
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
        displayLabel
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
      ${digitalObjectResourcesFields},
      ... on Asset {
        assetType
        featuredThumbnailRegion
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
        displayLabel,
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

export const getDigitalObjectIDsQuery = gql`
query DigitalObjects($limit: Limit!, $offset: Offset = 0, $searchParams: SearchAttributes, $orderBy: OrderByInput){
  digitalObjects(limit: $limit, offset: $offset, searchParams: $searchParams, orderBy: $orderBy) {
    totalCount
    nodes {
      id
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
      userErrors {
        message
        path
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
      userErrors {
        message
        path
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
      userErrors {
        message
        path
      }
    }
  }
`;

export const createResourceMutation = gql`
  mutation CreateResource($input: CreateResourceInput!) {
    createResource(input: $input) {
      digitalObject {
        id,
        ${digitalObjectResourcesFields},
      }
    }
  }
`;

export const deleteResourceMutation = gql`
  mutation DeleteResource($input: DeleteResourceInput!) {
    deleteResource(input: $input) {
      digitalObject {
        id,
        ${digitalObjectResourcesFields},
      }
    }
  }
`;

export const deleteDigitalObjectMutation = gql`
  mutation DeleteDigitalObject($input: DeleteDigitalObjectInput!) {
    deleteDigitalObject(input: $input) {
      digitalObject {
        id
      }
    }
  }
`;

export const purgeDigitalObjectMutation = gql`
  mutation PurgeDigitalObject($input: PurgeDigitalObjectInput!) {
    purgeDigitalObject(input: $input) {
      digitalObject {
        id
      }
    }
  }
`;
