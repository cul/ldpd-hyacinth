import React from 'react';
import { Route, Switch } from 'react-router-dom';

import DigitalObjectImportIndex from './DigitalObjectImportIndex';
import DigitalObjectImportShow from './DigitalObjectImportShow';
import PageNotFound from '../../shared/PageNotFound';

function DigitalObjectImports() {
  return (
    <Switch>

      <Route exact path="/batch_imports/:id/digital_object_imports" component={DigitalObjectImportIndex} />

      <Route exact path="/batch_imports/:batchImportId/digital_object_imports/:id" component={DigitalObjectImportShow} />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default DigitalObjectImports;
