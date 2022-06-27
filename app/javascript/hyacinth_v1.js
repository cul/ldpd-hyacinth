import React from 'react';
import ReactDOM from 'react-dom';
import { ApolloProvider } from '@apollo/react-hooks';

import createApolloClient from './src/hyacinth_v1/utils/createApolloClient';
import './stylesheets/hyacinth_v1.scss'; // app css entry point
import App from './src/hyacinth_v1/App'; // app js entry point
import getGraphqlSchemaTypes from './src/hyacinth_v1/utils/getGraphqlSchemaTypes';

document.addEventListener('DOMContentLoaded', () => {
  getGraphqlSchemaTypes().then((graphqlSchemaTypes) => {
    ReactDOM.render(
      (
        <ApolloProvider client={createApolloClient(graphqlSchemaTypes)}>
          <App />
        </ApolloProvider>
      ),
      document.getElementById('hyacinth-ui-v1-app'),
    );
  });
});
