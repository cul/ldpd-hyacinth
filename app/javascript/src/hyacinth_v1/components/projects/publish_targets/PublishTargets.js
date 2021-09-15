import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../shared/PageNotFound';
import ProtectedRoute from '../../shared/routes/ProtectedRoute';

import PublishTargetsEdit from './PublishTargetsEdit';
import PublishTargetsShow from './PublishTargetsShow';

export default class PublishTargets extends React.PureComponent {
  render() {
    return (
      <div>
        <Switch>
          <ProtectedRoute
            exact
            path="/projects/:projectStringKey/publish_targets"
            component={PublishTargetsShow}
            requiredAbility={params => (
              { action: 'read', subject: 'Project', stringKey: params.projectStringKey }
            )}
          />

          <ProtectedRoute
            path="/projects/:projectStringKey/publish_targets/edit"
            component={PublishTargetsEdit}
            requiredAbility={params => (
              { action: 'update', subject: 'Project', stringKey: params.projectStringKey }
            )}
          />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
