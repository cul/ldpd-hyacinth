import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import FieldExportProfileIndex from './FieldExportProfileIndex';
import FieldExportProfileNew from './FieldExportProfileNew';
import FieldExportProfileEdit from './FieldExportProfileEdit';
import ProtectedRoute from '../ProtectedRoute';

export default class FieldExportProfiles extends React.PureComponent {
  render() {
    return (
      <Switch>
        <ProtectedRoute
          exact
          path="/field_export_profiles"
          component={FieldExportProfileIndex}
          requiredAbility={{ action: 'read', subject: 'FieldExportProfile' }}
        />
        <ProtectedRoute
          exact
          path="/field_export_profiles/new"
          component={FieldExportProfileNew}
          requiredAbility={{ action: 'create', subject: 'FieldExportProfile' }}
        />

        <ProtectedRoute
          path="/field_export_profiles/:id/edit"
          component={FieldExportProfileEdit}
          requiredAbility={params => (
            { action: 'update', subject: 'FieldExportProfiles', id: params.id }
          )}
        />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
