import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import DynamicFieldIndex from './DynamicFieldIndex';
// import DynamicFieldNew from './DynamicFieldNew';
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

        {/* <ProtectedRoute
          path="/users/new"
          component={UserNew}
          requiredAbility={ { action: 'create', subject: 'User' } }
        />

        <ProtectedRoute
          path="/users/:uid/edit"
          component={UserEdit}
          requiredAbility={ (params) => ({ action: 'update', subject: 'User', uid: params.uid }) }
        /> */}

        { /* When none of the above match, <NoMatch> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
