import React from 'react';
import { BrowserRouter } from 'react-router-dom';
import { QueryParamProvider } from 'use-query-params';

import MainContent from './MainContent';

function App() {
  return (
    <BrowserRouter basename="/ui/v1">
      <QueryParamProvider ReactRouterRoute={BrowserRouter.Route}>
        <MainContent />
      </QueryParamProvider>
    </BrowserRouter>
  );
}

export default App;
