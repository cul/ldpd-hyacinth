import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../shared/PageNotFound';
import PublishTargetIndex from './PublishTargetIndex';
import PublishTargetNew from './PublishTargetNew';
import PublishTargetEdit from './PublishTargetEdit';
import ProtectedRoute from '../../shared/routes/ProtectedRoute';

export default class PublishTarget extends React.PureComponent {
  render() {
    return (
      <Switch>
        <ProtectedRoute
          exact
          path="/projects/:projectStringKey/publish_targets"
          component={PublishTargetIndex}
          requiredAbility={params => ({ action: 'read', subject: 'PublishTarget', project: { stringKey: params.projectStringKey } })}
        />

        <ProtectedRoute
          path="/projects/:projectStringKey/publish_targets/new"
          component={PublishTargetNew}
          requiredAbility={params => ({ action: 'create', subject: 'PublishTarget', project: { stringKey: params.projectStringKey } })}
        />

        <ProtectedRoute
          exact
          path="/projects/:projectStringKey/publish_targets/:stringKey/edit"
          component={PublishTargetEdit}
          requiredAbility={params => ({ action: 'update', subject: 'PublishTarget', project: { stringKey: params.projectStringKey } })}
        />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
