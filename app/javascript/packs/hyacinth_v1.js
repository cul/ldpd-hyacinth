import React from 'react';
import ReactDOM from 'react-dom';

import '../hyacinth_v1/stylesheets/hyacinth_v1.scss'; // app css entry point
import '../hyacinth_v1/utils/fontAwesome';

import App from '../hyacinth_v1/App'; // app js entry point

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />, document.getElementById('hyacinth-ui-v1-app'),
  );
});
