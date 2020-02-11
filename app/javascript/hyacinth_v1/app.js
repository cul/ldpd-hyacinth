import React, { useState } from 'react';
import { Route, Redirect, Switch } from 'react-router-dom';
import { Container } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import TopNavbar from '@hyacinth_v1/components/layout/TopNavbar';
import PageNotFound from './components/layout/PageNotFound';
import DigitalObjects from './components/digital_objects/DigitalObjects';
import Users from './components/users/Users';
import DynamicFields from './components/dynamic_fields/DynamicFields';
import DynamicFieldGroups from './components/dynamic_field_groups/DynamicFieldGroups';
import DynamicFieldCategories from './components/dynamic_field_categories/DynamicFieldCategories';
import FieldExportProfiles from './components/field_export_profiles/FieldExportProfiles';
import ControlledVocabularies from './components/controlled_vocabularies/ControlledVocabularies';
import Projects from './components/projects/Projects';
import { AbilityContext } from './util/ability_context';
import ability from './util/ability';
import { setupPermissionActions } from './util/permission_actions';
import { getAuthenticatedUserQuery } from './graphql/users';
import { getPermissionActionsQuery } from './graphql/permissionActions';
import GraphQLErrors from './components/ui/GraphQLErrors';

const Index = () => (
  <div>
    { /* TODO: If not logged in, redirect to login screen */ }
    <Redirect to="/digital_objects" />
  </div>
);

function App() {
  const [user, setUser] = useState({});

  const { loading: userLoading, error: userError } = useQuery(
    getAuthenticatedUserQuery,
    {
      onCompleted: (userData) => {
        const { authenticatedUser: { rules, ...rest } } = userData;
        ability.update(rules);
        setUser({ ...rest });
      },
    },
  );

  const { loading: permissionActionsLoading, error: permissionActionsError } = useQuery(
    getPermissionActionsQuery,
    {
      onCompleted: (permissionActionData) => {
        const {
          permissionActions: { projectActions, primaryProjectActions, aggregatorProjectActions }
        } = permissionActionData;
        setupPermissionActions(projectActions, primaryProjectActions, aggregatorProjectActions);
      },
    },
  );

  if (userLoading || permissionActionsLoading) return (<></>);
  if (userError || permissionActionsError) return (<GraphQLErrors errors={userError || permissionActionsError} />);

  return (
    <AbilityContext.Provider value={ability}>
      <TopNavbar user={user} />
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
          <Route path="/controlled_vocabularies" component={ControlledVocabularies} />
          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route path="/404" component={PageNotFound} />
          <Route component={PageNotFound} />
        </Switch>
      </Container>
    </AbilityContext.Provider>
  );
}

export default App;