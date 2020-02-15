import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import DynamicFieldCategoryNew from './DynamicFieldCategoryNew';
import DynamicFieldCategoryEdit from './DynamicFieldCategoryEdit';
import ProtectedRoute from '../shared/routes/ProtectedRoute';

export default class DynamicFieldCategories extends React.PureComponent {
  render() {
    return (
      <Switch>
        <ProtectedRoute
          exact
          path="/dynamic_field_categories/new"
          component={DynamicFieldCategoryNew}
          requiredAbility={{ action: 'create', subject: 'DynamicFieldCategory' }}
        />

        <ProtectedRoute
          path="/dynamic_field_categories/:id/edit"
          component={DynamicFieldCategoryEdit}
          requiredAbility={params => ({ action: 'update', subject: 'DynamicFieldCategory', id: params.id })}
        />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
