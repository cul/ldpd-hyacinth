import React from 'react';
import { Route, Switch } from 'react-router-dom';

import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch';
import PublishTargetIndex from './PublishTargetIndex';
import PublishTargetNew from './PublishTargetNew';
import PublishTargetEdit from './PublishTargetEdit';

export default class PublishTarget extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path="/projects/:projectStringKey/publish_targets" component={PublishTargetIndex} />
          <Route path="/projects/:projectStringKey/publish_targets/new" component={PublishTargetNew} />
          <Route path="/projects/:projectStringKey/publish_targets/:stringKey/edit" component={PublishTargetEdit} />

          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={NoMatch} />
        </Switch>
      </div>
    );
  }
}
