import React from 'react';
import { Route, Redirect, Switch } from 'react-router-dom';
import { Container } from 'react-bootstrap';
import produce from 'immer';

import TopNavbar from './components/layout/TopNavbar';
import PageNotFound from './components/layout/PageNotFound';
import DigitalObjects from './components/digital_objects/DigitalObjects';
import Users from './components/users/Users';
import DynamicFields from './components/dynamic_fields/DynamicFields';
import DynamicFieldGroups from './components/dynamic_field_groups/DynamicFieldGroups';
import DynamicFieldCategories from './components/dynamic_field_categories/DynamicFieldCategories';
import FieldExportProfiles from './components/field_export_profiles/FieldExportProfiles';
import Projects from './components/projects/Projects';
import { AbilityContext } from './util/ability_context';
import ability from './util/ability';
import hyacinthApi from './util/hyacinth_api';

const APPLICATION_BASE_PATH = '/ui/v1';

const Index = () => (
  <div>
    { /* TODO: If not logged in, redirect to login screen */ }
    <Redirect to="/digital_objects" />
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

        this.setState(produce((draft) => {
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
            <Route path="/digital_objects" component={DigitalObjects} />
            <Route path="/users" component={Users} />
            <Route path="/projects" component={Projects} />
            <Route path="/dynamic_fields" component={DynamicFields} />
            <Route path="/dynamic_field_groups" component={DynamicFieldGroups} />
            <Route path="/dynamic_field_categories" component={DynamicFieldCategories} />
            <Route path="/field_export_profiles" component={FieldExportProfiles} />
            { /* When none of the above match, <PageNotFound> will be rendered */ }
            <Route path="/404" component={PageNotFound} />
            <Route component={PageNotFound} />
          </Switch>
        </Container>
      </AbilityContext.Provider>
    );
  }
}
