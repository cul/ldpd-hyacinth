import axios from 'axios';

export const loadSchemaTypes = (onSuccess, onError) => {
  axios({
    method: 'post',
    headers: { 'Content-Type': 'application/json' },
    url: '/graphql',
    data: JSON.stringify({
      variables: {},
      query: `
        {
          __schema {
            types {
              kind
              name
              possibleTypes {
                name
              }
            }
          }
        }
      `,
    }),
  }).then((response) => {
    const result = response.data;
    /* eslint-disable no-underscore-dangle */
    // Filtering out any type information unrelated to unions or interfaces.
    const filteredData = result.data.__schema.types.filter(
      type => type.possibleTypes !== null,
    );
    result.data.__schema.types = filteredData;
    /* eslint-enable no-underscore-dangle */
    onSuccess(result.data);
  }).catch(() => onError());
};

export const loadPermissionActions = (onSuccess, onError) => {
  axios({
    method: 'post',
    headers: { 'Content-Type': 'application/json' },
    url: '/graphql',
    data: JSON.stringify({
      variables: {},
      query: `
        {
          permissionActions {
            projectActions
            primaryProjectActions
            aggregatorProjectActions
          }
        }
      `,
    }),
  }).then(response => onSuccess(response.data.data.permissionActions)).catch(() => onError());
};
