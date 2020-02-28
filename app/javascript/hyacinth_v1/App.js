import React, { useState, useEffect } from 'react';
import { BrowserRouter } from 'react-router-dom';
import { QueryParamProvider } from 'use-query-params';
import { ApolloProvider } from '@apollo/react-hooks';

import MainContent from './MainContent';
import createApolloClient from './utils/createApolloClient';
import { loadSchemaTypes, loadPermissionActions } from './utils/appLoaders';
import { setupPermissionActions } from './utils/permissionActions';

function App() {
  const [loadingSchemaTypes, setLoadingSchemaTypes] = useState(true);
  const [loadingPermissionActions, setLoadingPermissionActions] = useState(true);
  const [errors, setErrors] = useState(false);
  const [schemaTypes, setSchemaTypes] = useState({});

  // On app load we need to query for a portion of the graphql schema that will help
  // configure our Apollo instance.
  useEffect(() => {
    loadSchemaTypes((types) => {
      setSchemaTypes(types);
      setLoadingSchemaTypes(false);
    }, () => setErrors(true));

    loadPermissionActions((permissionActions) => {
      setupPermissionActions(permissionActions);
      setLoadingPermissionActions(false);
    }, () => setErrors(true));
  }, []);

  if (loadingSchemaTypes || loadingPermissionActions) return (<></>);
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
