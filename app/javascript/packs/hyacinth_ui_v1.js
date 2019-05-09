import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter as Router } from 'react-router-dom';

import Constants from 'hyacinth_ui_v1/Constants';

// app js entry point
import App from 'hyacinth_ui_v1/app';
// app css entry point
import 'hyacinth_ui_v1/stylesheets/hyacinth_ui_v1';

// add app-wide support for FontAwesome
import 'hyacinth_ui_v1/util/FontAwesome';

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Router basename={Constants.APPLICATION_BASE_PATH}>
      <App />
    </Router>,
    document.getElementById('hyacinth-ui-v1-app'),
  );
});
