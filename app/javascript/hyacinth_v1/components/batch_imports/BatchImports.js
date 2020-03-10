import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import ProtectedRoute from '../shared/routes/ProtectedRoute';
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

      {/* need to check  permissions somehow */}
      <Route exact path="/batch_imports/:id" component={BatchImportShow} />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default BatchImports;
