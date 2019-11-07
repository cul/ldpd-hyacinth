import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter } from 'react-router-dom';
import ApolloClient from 'apollo-boost';
import { ApolloProvider } from '@apollo/react-hooks';

import Constants from '../hyacinth_ui_v1/Constants';

// app js entry point
import App from '../hyacinth_ui_v1/app';
// app css entry point
import '../hyacinth_ui_v1/stylesheets/hyacinth_ui_v1.scss';

// add app-wide support for FontAwesome
import '../hyacinth_ui_v1/util/FontAwesome';

const client = new ApolloClient({
  uri: '/graphql',
});

// Apollo is no longer caching data. This configuration fetches
// fresh data with every page request. In order to use cached data
// addition and deletion requests need to be set up with methods that
// update the cache. Additionally, using cached data on the client
// side can lead to unexpected behaviors if another user is editing
// the same data.
client.defaultOptions = {
  watchQuery: {
    errorPolicy: 'none',
    fetchPolicy: 'no-cache',
  },
  query: {
    errorPolicy: 'none',
    fetchPolicy: 'no-cache',
  },
  mutation: {
    errorPolicy: 'none',
  },
};


document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <BrowserRouter basename={Constants.APPLICATION_BASE_PATH}>
      <ApolloProvider client={client}>
        <App />
      </ApolloProvider>
    </BrowserRouter>,
    document.getElementById('hyacinth-ui-v1-app'),
  );
});
