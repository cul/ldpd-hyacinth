export default async () => {
  const response = await fetch('/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
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
  });
  const jsonResponse = await response.json();

  // Filter out any type information unrelated to unions or interfaces.
  // eslint-disable-next-line no-underscore-dangle
  const filteredData = jsonResponse.data.__schema.types.filter((type) => type.possibleTypes !== null);
  // eslint-disable-next-line no-underscore-dangle
  jsonResponse.data.__schema.types = filteredData;

  return jsonResponse.data;
};
