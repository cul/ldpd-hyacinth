import React from 'react'
import { Route, Link, Redirect, Switch } from "react-router-dom";
import TopNavbar from 'hyacinth_ui_v1/components/layout/TopNavbar'
import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch'
import DigitalObjects from 'hyacinth_ui_v1/components/digital_objects/DigitalObjects'

const APPLICATION_BASE_PATH = '/ui/v1';

const Index = () => <div>
  { /* TODO: If not logged in, redirect to login screen */ }
  <Redirect to="/digital-objects" />
</div>;

export default class App extends React.Component {
  render() {
    return(
      <div>
        <TopNavbar />
        <div id="main">
          <Switch>
            <Route exact path="/" component={Index} />
            <Route path="/digital-objects" component={DigitalObjects} />
            { /* When none of the above match, <NoMatch> will be rendered */ }
            <Route component={NoMatch} />
          </Switch>
        </div>
      </div>
    )
  }

}
