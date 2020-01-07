import React from 'react';
import { Route, Switch, useRouteMatch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import RightsShow from './RightsShow';
import ItemRightsForm from './ItemRightsForm';
import DigitalObjectProtectedRoute from '../../DigitalObjectProtectedRoute';

function Rights(props) {
  const { path } = useRouteMatch();
  const { minimalDigitalObject } = props;

  return (
    <Switch>
      <Route exact path={path} component={RightsShow} />
      <DigitalObjectProtectedRoute
        path={`${path}/edit`}
        render={() => {
          switch (minimalDigitalObject.digitalObjectType) {
            case 'item':
              return <ItemRightsForm />;
            default:
              return `Rights edit view is not supported for digital object type: ${minimalDigitalObject.digitalObjectType}`;
          }
        }}
        requiredAbility={{ action: 'assess_rights', primaryProject: minimalDigitalObject.primaryProject, otherProjects: minimalDigitalObject.otherProjects }}
      />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default Rights;
