import React from 'react';
import { Route, Switch } from 'react-router-dom';

import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch';
import UserIndex from './UserIndex';
import UserNew from './UserNew';
import UserEdit from './UserEdit';

export default class Users extends React.Component {
  render() {
    return(
      <div>
        <Switch>
          <Route exact path="/users" component={UserIndex} />
          <Route path="/users/new" component={UserNew} />
          <Route path="/users/:uid/edit" component={UserEdit} />
          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={NoMatch} />
        </Switch>
      </div>
    )
  }
}
