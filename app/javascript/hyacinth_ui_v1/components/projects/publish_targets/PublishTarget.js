import React from 'react'
import { Link, Route, Switch } from "react-router-dom";

import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch'
import PublishTargetIndex from 'hyacinth_ui_v1/components/projects/publish_targets/PublishTargetIndex'
import PublishTargetNew from 'hyacinth_ui_v1/components/projects/publish_targets/PublishTargetNew'
import PublishTargetEdit from 'hyacinth_ui_v1/components/projects/publish_targets/PublishTargetEdit'

export default class PublishTarget extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path={`${this.props.match.path}`} component={PublishTargetIndex} />
          <Route path={`${this.props.match.path}/new`} component={PublishTargetNew} />
          <Route path={`${this.props.match.path}/:publish_target_string_key/edit`} component={PublishTargetEdit} />

          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={NoMatch} />
        </Switch>
      </div>
    )
  }
}