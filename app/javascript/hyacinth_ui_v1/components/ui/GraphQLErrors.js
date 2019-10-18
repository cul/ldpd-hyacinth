import React from 'react';
import { Alert } from 'react-bootstrap';

function GraphQLErrors({ errors }) {
  if (!errors) return (null);

  return (
    <Alert variant="danger">
      {
        errors.graphQLErrors && (
          <>
            <Alert.Heading as="h5">The following error(s) occurred:</Alert.Heading>
            <ul>
              {
                errors.graphQLErrors.map((error, eIndex) => (
                  error.message.split('; ').map((str, mIndex) => (
                    <li key={`${eIndex}_${mIndex}`}>{str}</li>
                  ))
                ))
              }
            </ul>
          </>
        )
      }
      { errors.networkError && `Network Error: ${errors.networkError.message}` }
    </Alert>
  );
}

export default GraphQLErrors;
