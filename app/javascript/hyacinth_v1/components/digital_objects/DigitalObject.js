import React from 'react';
import {
  Route, Switch, Redirect, useParams, useRouteMatch,
} from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import PageNotFound from '../layout/PageNotFound';
import RightsShow from './rights/RightsShow';
import RightsEdit from './rights/RightsEdit';
import MetadataShow from './metadata/MetadataShow';
import MetadataEdit from './metadata/MetadataEdit';
import Children from './children/Children';
import Assignments from './assignments/Assignments';
import PreservePublish from './preserve_publish/PreservePublish';
import SystemData from './system_data/SystemData';
import AssetData from './asset_data/AssetData';
import GraphQLErrors from '../ui/GraphQLErrors';
import DigitalObjectProtectedRoute from '../DigitalObjectProtectedRoute';

import { getMinimalDigitalObjectWithProjectsQuery } from '../../graphql/digitalObjects';

function DigitalObject() {
  const { id } = useParams();
  const { path } = useRouteMatch();

  const {
    loading: minimalDigitalObjectLoading,
    error: minimalDigitalObjectError,
    data: minimalDigitalObjectData,
  } = useQuery(getMinimalDigitalObjectWithProjectsQuery, {
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
            { routePath: `${path}/system_data`, Component: SystemData, action: 'read_objects' },
            { routePath: `${path}/metadata/edit`, Component: MetadataEdit, action: 'update_objects' },
            { routePath: `${path}/metadata`, Component: MetadataShow, action: 'read_objects' },
            { routePath: `${path}/rights/edit`, Component: RightsEdit, action: 'assess_rights' },
            { routePath: `${path}/rights`, Component: RightsShow, action: 'read_objects' },
            { routePath: `${path}/children`, Component: Children, action: 'read_objects' },
            { routePath: `${path}/preserve_publish`, Component: PreservePublish, action: 'read_objects' },
            { routePath: `${path}/assignments`, Component: Assignments, action: 'read_objects' },
          ].map((entry) => {
            const { routePath, Component, action } = entry;
            return (
              <DigitalObjectProtectedRoute
                key={routePath}
                path={routePath}
                render={() => <Component id={minimalDigitalObject.id} />}
                requiredAbility={{
                  action,
                  primaryProject: minimalDigitalObject.primaryProject,
                  otherProjects: minimalDigitalObject.otherProjects,
                }}
              />
            );
          })
        }

        { minimalDigitalObject.digitalObjectType === 'asset'
          && (
            <DigitalObjectProtectedRoute
              key="assetData"
              path={`${path}/asset_data`}
              render={() => <AssetData id={minimalDigitalObject.id} />}
              requiredAbility={{
                action: 'read_objects',
                primaryProject: minimalDigitalObject.primaryProject,
                otherProjects: minimalDigitalObject.otherProjects,
              }}
            />
          )
        }

        <Redirect exact from={path} to="/digital_objects/:id/metadata" />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    </div>
  );
}

export default DigitalObject;
