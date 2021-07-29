import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../shared/PageNotFound';
import FieldSetIndex from './FieldSetIndex';
import FieldSetNew from './FieldSetNew';
import FieldSetEdit from './FieldSetEdit';
import ProtectedRoute from '../../shared/routes/ProtectedRoute';

export default class FieldSet extends React.PureComponent {
  render() {
    return (
      <div>
        <Switch>
          <ProtectedRoute
            exact
            path="/projects/:projectStringKey/field_sets"
            component={FieldSetIndex}
            requiredAbility={params => (
              { action: 'read', subject: 'FieldSet', project: { stringKey: params.projectStringKey } }
            )}
          />

          <ProtectedRoute
            path="/projects/:projectStringKey/field_sets/new"
            component={FieldSetNew}
            requiredAbility={params => (
              { action: 'create', subject: 'FieldSet', project: { stringKey: params.projectStringKey } }
            )}
          />

          <ProtectedRoute
            path="/projects/:projectStringKey/field_sets/:id/edit"
            component={FieldSetEdit}
            requiredAbility={params => ({ action: 'update', subject: 'FieldSet', project: { stringKey: params.projectStringKey } })}
          />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
