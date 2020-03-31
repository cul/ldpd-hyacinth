import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import BatchImportIndex from './BatchImportIndex';
import BatchImportShow from './BatchImportShow';
import BatchImportNew from './BatchImportNew';
import DigitalObjectImports from './digital_object_imports/DigitalObjectImports';

function BatchImports() {
  return (
    <Switch>
      <Route exact path="/batch_imports" component={BatchImportIndex} />
      <Route exact path="/batch_imports/new" component={BatchImportNew} />
      <Route path="/batch_imports/:id/digital_object_imports" component={DigitalObjectImports} />

      {/*
        Cannot check permissions because we need to retrieve the batch import
        in order to check if the user has the correct permissions. We will
        default to rendering permissions errors raised by the GraphQL query.
      */}
      <Route exact path="/batch_imports/:id" component={BatchImportShow} />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default BatchImports;
