import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../shared/PageNotFound';
import PermissionsShow from './PermissionsShow';
import PermissionsEdit from './PermissionsEdit';
import ProtectedRoute from '../../shared/routes/ProtectedRoute';

export default class Permissions extends React.PureComponent {
  render() {
    const { match: { path } } = this.props;
    return (
      <Switch>
        <ProtectedRoute
          exact
          path={`${path}`}
          component={PermissionsShow}
          requiredAbility={params => (
            { action: 'read', subject: 'Project', stringKey: params.stringKey }
          )}
        />

        <ProtectedRoute
          path={`${path}/edit`}
          component={PermissionsEdit}
          requiredAbility={params => (
            { action: 'update', subject: 'Project', stringKey: params.stringKey }
          )}
        />

        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
