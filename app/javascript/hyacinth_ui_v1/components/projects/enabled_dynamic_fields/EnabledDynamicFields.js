import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
// import EnabledDynamicFieldShow from './EnabledDynamicFieldShow';
// import EnabledDynamicFieldEdit from './EnabledDynamicFieldEdit';

export default class EnabledDynamicFields extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path="/projects/:projectStringKey/enabled_dynamic_fields/:digitalObjectType" component={EnabledDynamicFieldShow} />
          <Route path="/projects/:projectStringKey/enabled_dynamic_fields/:digitalObjectType/edit" component={EnabledDynamicFieldEdit} />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
