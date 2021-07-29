import React from 'react';
import ReactDOM from 'react-dom';

import '../stylesheets/hyacinth_v1.scss'; // app css entry point
import '../src/hyacinth_v1/utils/fontAwesome';

import App from '../src/hyacinth_v1/App'; // app js entry point

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <App />, document.getElementById('hyacinth-ui-v1-app'),
  );
});
