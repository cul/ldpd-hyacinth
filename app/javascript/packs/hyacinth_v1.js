import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter } from 'react-router-dom';
import ApolloClient from 'apollo-boost';
import { ApolloProvider } from '@apollo/react-hooks';

// app js entry point
import App from '../hyacinth_v1/app';
// app css entry point
import '../hyacinth_v1/stylesheets/hyacinth_v1.scss';

// add app-wide support for FontAwesome
import '../hyacinth_v1/utils/fontAwesome';

const client = new ApolloClient({
  uri: '/graphql',
});

// Apollo is no longer caching data. This configuration fetches
// fresh data with every page request. In order to use cached data,
// addition and deletion requests need to be set up with methods that
// update the cache. Additionally, using cached data on the client
// side can lead to unexpected behaviors if another user is editing
// the same data.
//
// Using network-only fetch policy instead of no-cache because updating results
// using fetchMore doesn't work when using a no-cache policy. This policy will
// not display any stale results and will always make a request.
// More information: https://github.com/apollographql/apollo-client/issues/5239
client.defaultOptions = {
  watchQuery: {
    errorPolicy: 'none',
    fetchPolicy: 'network-only',
  },
  query: {
    errorPolicy: 'none',
    fetchPolicy: 'network-only',
  },
  mutation: {
    errorPolicy: 'none',
  },
  addTypename: false,
};


document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <BrowserRouter basename="/ui/v1">
      <ApolloProvider client={client}>
        <App />
      </ApolloProvider>
    </BrowserRouter>,
    document.getElementById('hyacinth-ui-v1-app'),
  );
});
