import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from 'hyacinth_ui_v1/components/layout/PageNotFound';
import PublishTargetIndex from './PublishTargetIndex';
import PublishTargetNew from './PublishTargetNew';
import PublishTargetEdit from './PublishTargetEdit';
import ProtectedRoute from '../../ProtectedRoute';

export default class PublishTarget extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path="/projects/:projectStringKey/publish_targets" component={PublishTargetIndex} />

          <ProtectedRoute
            path="/projects/:projectStringKey/publish_targets/new"
            component={PublishTargetNew}
            requiredAbility={(params) => ({ action: "create", subject: "PublishTarget", project: { stringKey: params.projectStringKey }})}
          />

          <ProtectedRoute
            exact
            path="/projects/:projectStringKey/publish_targets/:stringKey/edit"
            component={PublishTargetEdit}
            requiredAbility={(params) => ({ action: "update", subject: "PublishTarget", project: { stringKey: params.projectStringKey }})}
          />

          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
