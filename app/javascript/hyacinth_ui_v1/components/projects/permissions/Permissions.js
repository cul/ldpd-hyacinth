import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import PermissionsShow from './PermissionsShow';
import PermissionsEdit from './PermissionsEdit';
import ProtectedRoute from '../../ProtectedRoute';

export default class Permissions extends React.PureComponent {
  render() {
    const { match: { path } } = this.props;
    return (
      <Switch>
        <Route exact path={`${path}`} component={PermissionsShow} />

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
