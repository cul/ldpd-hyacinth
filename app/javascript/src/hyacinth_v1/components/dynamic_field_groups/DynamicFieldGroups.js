import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import DynamicFieldGroupNew from './DynamicFieldGroupNew';
import DynamicFieldGroupEdit from './DynamicFieldGroupEdit';
import ProtectedRoute from '../shared/routes/ProtectedRoute';

function DynamicFieldGroups() {
  return (
    <Switch>
      <ProtectedRoute
        exact
        path="/dynamic_field_groups/new"
        component={DynamicFieldGroupNew}
        requiredAbility={{ action: 'create', subject: 'DynamicFieldGroup' }}
      />

      <ProtectedRoute
        path="/dynamic_field_groups/:id/edit"
        component={DynamicFieldGroupEdit}
        requiredAbility={params => (
          { action: 'update', subject: 'DynamicFieldGroup', id: params.id }
        )}
      />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default DynamicFieldGroups;
