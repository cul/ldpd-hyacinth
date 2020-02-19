import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import ExportJobIndex from './ExportJobIndex';

function ExportJobs() {
  return (
    <Switch>
      <Route exact path="/export_jobs" component={ExportJobIndex} />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default ExportJobs;
