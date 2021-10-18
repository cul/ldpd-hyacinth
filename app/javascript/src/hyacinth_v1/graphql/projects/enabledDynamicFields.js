import gql from 'graphql-tag';

const getEnabledDynamicFieldsFields = `
project {
  stringKey
}
digitalObjectType
`;

export const getEnabledDynamicFieldsQuery = gql`
  query($project: StringKey!, $digitalObjectType: DigitalObjectTypeEnum!) {
    enabledDynamicFields(project: $project, digitalObjectType: $digitalObjectType) {
      type: __typename
      project {
        stringKey
      }
      digitalObjectType
      dynamicField {
        id
      }
      fieldSets {
        id
      }
      enabled
      required
      locked
      hidden
      ownerOnly
      defaultValue
      shareable
    }
  }
`;

export const updateEnabledDynamicFieldsMutation = gql`
  mutation ($input: UpdateProjectEnabledFieldsInput!) {
    updateProjectEnabledFields(input: $input) {
      projectEnabledFields {
        ${getEnabledDynamicFieldsFields}
        dynamicField {
          id
        }
        fieldSets {
          id
        }
        required
        locked
        hidden
        ownerOnly
        defaultValue
        shareable
      }
      userErrors {
        message
        path
      }
    }
  }
`;
