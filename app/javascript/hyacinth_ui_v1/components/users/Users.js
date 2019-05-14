import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import UserIndex from './UserIndex';
import UserNew from './UserNew';
import UserEdit from './UserEdit';
import ProtectedRoute from '../ProtectedRoute';

export default class Users extends React.Component {
  render() {
    return (
      <Switch>
        <ProtectedRoute
          exact
          path="/users"
          component={UserIndex}
          requiredAbility={ { action: 'index', subject: 'User' } }
        />

        <ProtectedRoute
          path="/users/new"
          component={UserNew}
          requiredAbility={ { action: 'create', subject: 'User' } }
        />

        <ProtectedRoute
          path="/users/:uid/edit"
          component={UserEdit}
          requiredAbility={ (params) => ({ action: 'update', subject: 'User', uid: params.uid }) }
        />

        { /* When none of the above match, <NoMatch> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
