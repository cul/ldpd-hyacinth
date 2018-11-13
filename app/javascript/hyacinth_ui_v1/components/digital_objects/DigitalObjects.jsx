import React from 'react'
import { Link, Route, Switch } from "react-router-dom";
import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'
import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch'
import DigitalObjectSearch from 'hyacinth_ui_v1/components/digital_objects/DigitalObjectSearch'
import DigitalObjectNew from 'hyacinth_ui_v1/components/digital_objects/DigitalObjectNew'
import DigitalObjectEdit from 'hyacinth_ui_v1/components/digital_objects/DigitalObjectEdit'
import DigitalObjectShow from 'hyacinth_ui_v1/components/digital_objects/DigitalObjectShow'

export default class DigitalObjects extends React.Component {

  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div>
        <Switch>
          <Route exact path="/digital-objects" component={DigitalObjectSearch} />
          <Route path="/digital-objects/new" component={DigitalObjectNew} />
          <Route path="/digital-objects/:uuid/edit" component={DigitalObjectEdit} />
          <Route path="/digital-objects/:uuid" component={DigitalObjectShow} />
          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={NoMatch} />
        </Switch>
      </div>
    )
  }
}
