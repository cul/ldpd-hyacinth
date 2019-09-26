import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter as Router } from 'react-router-dom';
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


document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Router basename={Constants.APPLICATION_BASE_PATH}>
      <ApolloProvider client={client}>
        <App />
      </ApolloProvider>
    </Router>,
    document.getElementById('hyacinth-ui-v1-app'),
  );
});
