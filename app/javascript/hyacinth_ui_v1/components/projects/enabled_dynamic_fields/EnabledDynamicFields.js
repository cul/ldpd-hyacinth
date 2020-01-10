import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import ProtectedRoute from '../../ProtectedRoute';

import EnabledDynamicFieldEdit from './EnabledDynamicFieldEdit';
import EnabledDynamicFieldShow from './EnabledDynamicFieldShow';

export default class EnabledDynamicFields extends React.PureComponent {
  render() {
    return (
      <div>
        <Switch>
          <ProtectedRoute
            exact
            path="/projects/:projectStringKey/enabled_dynamic_fields/:digitalObjectType"
            component={EnabledDynamicFieldShow}
            requiredAbility={params => (
              { action: 'read', subject: 'Project', stringKey: params.projectStringKey }
            )}
          />

          <ProtectedRoute
            path="/projects/:projectStringKey/enabled_dynamic_fields/:digitalObjectType/edit"
            component={EnabledDynamicFieldEdit}
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
