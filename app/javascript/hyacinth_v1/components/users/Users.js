import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import UserIndex from './UserIndex';
import UserNew from './UserNew';
import UserEdit from './UserEdit';
import ProtectedRoute from '../shared/routes/ProtectedRoute';

export default class Users extends React.PureComponent {
  render() {
    return (
      <Switch>
        <ProtectedRoute
          exact
          path="/users"
          component={UserIndex}
          requiredAbility={{ action: 'manage', subject: 'User' }}
        />

        <ProtectedRoute
          path="/users/new"
          component={UserNew}
          requiredAbility={{ action: 'create', subject: 'User' }}
        />

        <ProtectedRoute
          path="/users/:uid/edit"
          component={UserEdit}
          requiredAbility={params => ({ action: 'update', subject: 'User', uid: params.uid })}
        />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
