import React from 'react';
import { Route, Switch } from 'react-router-dom';
import PageNotFound from '../shared/PageNotFound';
import ProtectedRoute from '../shared/routes/ProtectedRoute';
import PublishTargetEdit from './PublishTargetEdit';
import PublishTargetIndex from './PublishTargetIndex';
import PublishTargetNew from './PublishTargetNew';
import PublishTargetShow from './PublishTargetShow';


function PublishTargets() {
  return (
    <Switch>
      <ProtectedRoute
        exact
        path="/publish_targets"
        requiredAbility={{ action: 'read', subjectType: 'PublishTarget' }}
        component={PublishTargetIndex}
      />

      <ProtectedRoute
        exact
        path="/publish_targets/new"
        requiredAbility={{ action: 'create', subjectType: 'PublishTarget' }}
        component={PublishTargetNew}
      />

      <ProtectedRoute
        exact
        path="/publish_targets/:stringKey"
        component={PublishTargetShow}
        requiredAbility={params => ({ action: 'read', subject: 'PublishTarget', publishTarget: { stringKey: params.stringKey } })}
      />

      <ProtectedRoute
        exact
        path="/publish_targets/:stringKey/edit"
        component={PublishTargetEdit}
        requiredAbility={params => ({ action: 'update', subject: 'PublishTarget', publishTarget: { stringKey: params.stringKey } })}
      />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default PublishTargets;
