import React from 'react'
import { Link, Route, Switch } from "react-router-dom";

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'
import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch'
import CoreDataShow from 'hyacinth_ui_v1/components/projects/core_data/CoreDataShow'
import CoreDataEdit from 'hyacinth_ui_v1/components/projects/core_data/CoreDataEdit'

export default class CoreData extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path={`${this.props.match.path}`} component={CoreDataShow} />
          <Route path={`${this.props.match.path}/edit`} component={CoreDataEdit} />
        </Switch>
      </div>
    )
  }
}
