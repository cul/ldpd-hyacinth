import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../shared/PageNotFound';
import CoreDataShow from './CoreDataShow';
import CoreDataEdit from './CoreDataEdit';
import ProtectedRoute from '../../shared/routes/ProtectedRoute';

export default class CoreData extends React.PureComponent {
  render() {
    const { match: { path } } = this.props;
    return (
      <Switch>
        <ProtectedRoute
          exact
          path={`${path}`}
          component={CoreDataShow}
          requiredAbility={params => (
            { action: 'read', subject: 'Project', stringKey: params.stringKey }
          )}
        />

        <ProtectedRoute
          path={`${path}/edit`}
          component={CoreDataEdit}
          requiredAbility={params => (
            { action: 'update', subject: 'Project', stringKey: params.stringKey }
          )}
        />

        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
