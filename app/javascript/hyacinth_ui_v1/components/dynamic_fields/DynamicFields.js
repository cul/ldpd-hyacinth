import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import DynamicFieldIndex from './DynamicFieldIndex';
import DynamicFieldNew from './DynamicFieldNew';
import DynamicFieldEdit from './DynamicFieldEdit';
import ProtectedRoute from '../ProtectedRoute';

export default class DynamicFields extends React.Component {
  render() {
    return (
      <Switch>
        <ProtectedRoute
          exact
          path="/dynamic_fields"
          component={DynamicFieldIndex}
          requiredAbility={{ action: 'index', subject: 'DynamicField' }}
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

        { /* When none of the above match, <NoMatch> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
