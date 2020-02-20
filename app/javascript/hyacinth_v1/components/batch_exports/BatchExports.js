import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import BatchExportIndex from './BatchExportIndex';

function BatchExports() {
  return (
    <Switch>
      <Route exact path="/batch_exports" component={BatchExportIndex} />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default BatchExports;
