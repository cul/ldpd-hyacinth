import React from 'react';
import { Route, Switch } from 'react-router-dom';

import NoMatch from '../../layout/NoMatch';
import CoreDataShow from './CoreDataShow';
import CoreDataEdit from './CoreDataEdit';
import ProtectedRoute from '../../ProtectedRoute';

export default class CoreData extends React.Component {
  render() {
    return (
      <Switch>
        <Route exact path={`${this.props.match.path}`} component={CoreDataShow} />

        <ProtectedRoute
          path={`${this.props.match.path}/edit`}
          component={CoreDataEdit}
          requiredAbility={(params) => ({ action: "update", subject: "Project", stringKey: params.stringKey })}
        />

        <Route component={NoMatch} />
      </Switch>
    );
  }
}
