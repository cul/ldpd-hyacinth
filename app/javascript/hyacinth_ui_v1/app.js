import React from 'react';
import { Route, Redirect, Switch } from 'react-router-dom';
import { Container } from 'react-bootstrap';
import producer from 'immer';

import TopNavbar from 'hyacinth_ui_v1/components/layout/TopNavbar';
import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch';
import DigitalObjects from 'hyacinth_ui_v1/components/digital_objects/DigitalObjects';
import Users from 'hyacinth_ui_v1/components/users/Users';
import DynamicFields from 'hyacinth_ui_v1/components/dynamic_fields/DynamicFields';
import DynamicFieldGroups from 'hyacinth_ui_v1/components/dynamic_field_groups/DynamicFieldGroups';
import DynamicFieldCategories from 'hyacinth_ui_v1/components/dynamic_field_categories/DynamicFieldCategories';
import Projects from 'hyacinth_ui_v1/components/projects/Projects';
import { AbilityContext } from './util/ability_context';
import ability from './util/ability';
import hyacinthApi from './util/hyacinth_api';

const APPLICATION_BASE_PATH = '/ui/v1';

const Index = () => (
  <div>
    { /* TODO: If not logged in, redirect to login screen */ }
    <Redirect to="/digital-objects" />
  </div>
);

export default class App extends React.Component {
  state = {
    user: {
      firstName: '',
      lastName: '',
      uid: '',
    },
  }

  componentDidMount() {
    hyacinthApi.get('/users/authenticated')
      .then((res) => {
        const user = res.data;

        ability.update(user.rules);

        this.setState(producer((draft) => {
          draft.user.firstName = user.firstName;
          draft.user.lastName = user.lastName;
          draft.user.uid = user.uid;
        }));
      });
  }

  render() {
    return (
      <AbilityContext.Provider value={ability}>
        <TopNavbar user={this.state.user} />
        <Container id="main">
          <Switch>
            <Route exact path="/" component={Index} />
            <Route path="/digital-objects" component={DigitalObjects} />
            <Route path="/users" component={Users} />
            <Route path="/projects" component={Projects} />
            <Route path="/dynamic_fields" component={DynamicFields} />
            <Route path="/dynamic_field_groups" component={DynamicFieldGroups} />
            <Route path="/dynamic_field_categories" component={DynamicFieldCategories} />
            { /* When none of the above match, <NoMatch> will be rendered */ }
            <Route path="/404" component={NoMatch} />
            <Route component={NoMatch} />
          </Switch>
        </Container>
      </AbilityContext.Provider>
    );
  }
}
