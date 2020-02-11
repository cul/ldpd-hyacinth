import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import DynamicFieldIndex from './DynamicFieldIndex';
import DynamicFieldNew from './DynamicFieldNew';
import DynamicFieldEdit from './DynamicFieldEdit';
import ProtectedRoute from '../shared/routes/ProtectedRoute';

export default class DynamicFields extends React.PureComponent {
  render() {
    return (
      <Switch>
        <ProtectedRoute
          exact
          path="/dynamic_fields"
          component={DynamicFieldIndex}
          requiredAbility={{ action: 'read', subject: 'DynamicField' }}
        />

        <ProtectedRoute
          path="/dynamic_fields/new"
          component={DynamicFieldNew}
          requiredAbility={{ action: 'create', subject: 'DynamicField' }}
        />

        <ProtectedRoute
          path="/dynamic_fields/:id/edit"
          component={DynamicFieldEdit}
          requiredAbility={params => ({ action: 'update', subject: 'DynamicField', id: params.id })}
        />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
