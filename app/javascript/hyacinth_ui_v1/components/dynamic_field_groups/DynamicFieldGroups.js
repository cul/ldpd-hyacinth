import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import DynamicFieldGroupNew from './DynamicFieldGroupNew';
import DynamicFieldGroupEdit from './DynamicFieldGroupEdit';
import ProtectedRoute from '../ProtectedRoute';

export default class DynamicFieldGroups extends React.Component {
  render() {
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
          requiredAbility={params => ({ action: 'update', subject: 'DynamicFieldGroup', id: params.id })}
        />

        { /* When none of the above match, <NoMatch> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
