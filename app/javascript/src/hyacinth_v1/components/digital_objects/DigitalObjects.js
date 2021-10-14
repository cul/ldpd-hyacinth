import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import DigitalObjectNew from './new/DigitalObjectNew';
import DigitalObjectNewForm from './new/DigitalObjectNewForm';
import DigitalObjectSearch from './DigitalObjectSearch';
import DigitalObject from './DigitalObject';
import ProtectedRoute from '../shared/routes/ProtectedRoute';

function DigitalObjects() {
  return (
    <div>
      <Switch>
        <Route exact path="/digital_objects" component={DigitalObjectSearch} />
        <ProtectedRoute
          path="/digital_objects/new/:projectStringKey/:digitalObjectType"
          component={DigitalObjectNewForm}
          requiredAbility={(params) => (
            { action: 'create_objects', subject: 'Project', stringKey: params.projectStringKey }
          )}
        />
        <Route path="/digital_objects/new" component={DigitalObjectNew} />
        <Route path="/digital_objects/:id" component={DigitalObject} />
        <Route component={PageNotFound} />
      </Switch>
    </div>
  );
}

export default DigitalObjects;
