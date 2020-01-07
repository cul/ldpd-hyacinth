import React from 'react';
import {
  Route, Switch, Redirect, useParams, useRouteMatch,
} from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import PageNotFound from '../layout/PageNotFound';
import Rights from './rights/Rights';
import Metadata from './metadata/Metadata';
import Children from './children/Children';
import PreservePublish from './preserve_publish/PreservePublish';
import SystemData from './system_data/SystemData';
import GraphQLErrors from '../ui/GraphQLErrors';
import DigitalObjectProtectedRoute from '../DigitalObjectProtectedRoute';

import { getMinimalDigitalObjectQuery } from '../../graphql/digitalObjects';

function DigitalObject() {
  const { id } = useParams();
  const { path } = useRouteMatch();

  const {
    loading: minimalDigitalObjectLoading,
    error: minimalDigitalObjectError,
    data: minimalDigitalObjectData,
  } = useQuery(getMinimalDigitalObjectQuery, {
    variables: { id },
  });

  if (minimalDigitalObjectLoading) return (<></>);
  if (minimalDigitalObjectError) return (<GraphQLErrors errors={minimalDigitalObjectError} />);
  const { digitalObject: minimalDigitalObject } = minimalDigitalObjectData;

  return (
    <div>
      <Switch>
        {
          [
            { routePath: `${path}/system_data`, Component: SystemData },
            { routePath: `${path}/metadata`, Component: Metadata },
            { routePath: `${path}/rights`, Component: Rights },
            { routePath: `${path}/children`, Component: Children },
            { routePath: `${path}/preserve_publish`, Component: PreservePublish }
          ].map((entry) => {
            const { routePath, Component } = entry;
            return (
              <DigitalObjectProtectedRoute
                key={routePath}
                path={routePath}
                render={() => <Component minimalDigitalObject={minimalDigitalObject} />}
                requiredAbility={{ action: 'read_objects', primaryProject: minimalDigitalObject.primaryProject, otherProjects: minimalDigitalObject.otherProjects }}
              />
            );
          })
        }

        <Redirect exact from={path} to="/digital_objects/:id/metadata" />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    </div>
  );
}

export default DigitalObject;
