import React, { useState, useEffect } from 'react';
import { BrowserRouter } from 'react-router-dom';
import { QueryParamProvider } from 'use-query-params';
import { ApolloProvider } from '@apollo/react-hooks';
import axios from 'axios';

import MainContent from './MainContent';
import createApolloClient from './utils/createApolloClient';

function App() {
  const [loading, setLoading] = useState(true);
  const [errors, setErrors] = useState(false);
  const [schemaTypes, setSchemaTypes] = useState({});

  // On app load we need to query for a portion of the graphql schema that will help
  // configure our Apollo instance.
  useEffect(() => {
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
      setSchemaTypes(result.data);
      setLoading(false);
    }).catch(() => setErrors(true));
  }, []);

  if (loading) return (<></>);
  if (errors) return (<p>Error Loading GraphQL Schema.</p>);

  return (
    <BrowserRouter basename="/ui/v1">
      <QueryParamProvider ReactRouterRoute={BrowserRouter.Route}>
        <ApolloProvider client={createApolloClient(schemaTypes)}>
          <MainContent />
        </ApolloProvider>
      </QueryParamProvider>
    </BrowserRouter>
  );
}

export default App;
