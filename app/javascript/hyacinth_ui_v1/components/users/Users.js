import React from 'react'
import { Link, Route, Switch } from "react-router-dom";

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'
import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch'
import UserIndex from 'hyacinth_ui_v1/components/users/UserIndex'
import UserNew from 'hyacinth_ui_v1/components/users/UserNew'
import UserEdit from 'hyacinth_ui_v1/components/users/UserEdit'

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
