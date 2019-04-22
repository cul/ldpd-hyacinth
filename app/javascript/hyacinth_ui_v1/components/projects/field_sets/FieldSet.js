import React from 'react'
import { Link, Route, Switch } from "react-router-dom";

import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch'
import FieldSetIndex from 'hyacinth_ui_v1/components/projects/field_sets/FieldSetIndex'
import FieldSetNew from 'hyacinth_ui_v1/components/projects/field_sets/FieldSetNew'
import FieldSetEdit from 'hyacinth_ui_v1/components/projects/field_sets/FieldSetEdit'


export default class FieldSet extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path={`${this.props.match.path}`} component={FieldSetIndex} />
          <Route path={`${this.props.match.path}/new`} component={FieldSetNew} />
          {/* <Route exact path="/projects/:string_key" component={ProjectShow} /> */}
          <Route path={`${this.props.match.path}/:id/edit`} component={FieldSetEdit} />

          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={NoMatch} />
        </Switch>
      </div>
    )
  }
}
