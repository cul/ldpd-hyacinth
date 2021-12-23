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

const digitalObjectPublishPreserveInfoFields = `
  publishEntries {
    publishTarget {
      stringKey
    }
    publishedAt
    publishedBy {
      fullName
    }
  }
  availablePublishTargets
  preservedAt
`;

const userErrorsFields = `
  userErrors {
    message
    path
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

export const getChildStructureDigitalObjectQuery = gql`
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
        primaryProject {
          ${minimalDigitalObjectProjectFields}
        }
        otherProjects {
          ${minimalDigitalObjectProjectFields}
        }
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
      ${digitalObjectPublishPreserveInfoFields},
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
      ${userErrorsFields}
    }
  }
`;

export const updateDescriptiveMetadataMutation = gql`
  mutation UpdateDescriptiveMetadata($input: UpdateDescriptiveMetadataInput!) {
    updateDescriptiveMetadata(input: $input) {
      digitalObject {
        id
      }
      ${userErrorsFields}
    }
  }
`;

export const updateProjectsMutation = gql`
  mutation UpdateProjects($input: UpdateProjectsInput!) {
    updateProjects(input: $input) {
      digitalObject {
        id
        primaryProject {
          stringKey
          displayLabel
        }
        otherProjects {
          stringKey
          displayLabel
        }
      }
      ${userErrorsFields}
    }
  }
`;

export const updateRightsMutation = gql`
  mutation UpdateRights($input: UpdateRightsInput!) {
    updateRights(input: $input) {
      digitalObject {
        id
      }
      ${userErrorsFields}
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

export const publishDigitalObjectMutation = gql`
  mutation PublishDigitalObject($input: PublishDigitalObjectInput!) {
    publishDigitalObject(input: $input) {
      digitalObject {
        id
      }
      ${userErrorsFields}
    }
  }
`;

export const preserveDigitalObjectMutation = gql`
  mutation PreserveDigitalObject($input: PreserveDigitalObjectInput!) {
    preserveDigitalObject(input: $input) {
      digitalObject {
        id
      }
      ${userErrorsFields}
    }
  }
`;

export const updateChildStructureMutation = gql`
  mutation updateChildStructure($input: UpdateChildStructureInput!) {
    updateChildStructure(input: $input) {
      parent {
        id
      }
    }
  }
`;

export const removeParentMutation = gql`
  mutation removeParent($input: RemoveParentInput!) {
   removeParent(input: $input) {
     digitalObject {
       id
     }
   }
 }
`;

export const addParentMutation = gql`
  mutation addParent($input: AddParentInput!) {
   addParent(input: $input) {
     digitalObject {
       id
     }
   }
 }
`;
