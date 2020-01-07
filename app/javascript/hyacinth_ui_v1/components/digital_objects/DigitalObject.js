import React from 'react';
import { Route, Switch, Redirect, useParams, useRouteMatch } from 'react-router-dom';
import queryString from 'query-string';
import { useQuery } from '@apollo/react-hooks';

import PageNotFound from '../layout/PageNotFound';
import Rights from './rights/Rights';
import Metadata from './metadata/Metadata';
import Children from './children/Children';
import PreservePublish from './preserve_publish/PreservePublish';
import SystemData from './system_data/SystemData';
import GraphQLErrors from '../ui/GraphQLErrors';


import { getMinimalDigitalObjectQuery } from '../../graphql/digitalObjects';

function DigitalObject() {
  const { id } = useParams();
  const { path } = useRouteMatch();

  const { loading: minimalDigitalObjectLoading, erorr: minimalDigitalObjectError, data: minimalDigitalObjectData } = useQuery(getMinimalDigitalObjectQuery, { variables: { id } });

  if (minimalDigitalObjectLoading) return (<></>);
  if (minimalDigitalObjectError) return (<GraphQLErrors errors={minimalDigitalObjectError} />);
  const { digitalObject: minimalDigitalObject } = minimalDigitalObjectData;
  const projects = [minimalDigitalObject.primaryProject].concat(minimalDigitalObject.otherProjects);

  return (
    <div>
      <Switch>
        <Route path={`${path}/system_data`} component={SystemData} />
        <Route path={`${path}/metadata`} component={Metadata} />
        <Route path={`${path}/rights`} component={Rights} />
        <Route path={`${path}/children`} component={Children} />
        <Route path={`${path}/preserve_publish`} component={PreservePublish} />

        <Redirect exact from={path} to="/digital_objects/:id/metadata" />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    </div>
  );
}

export default DigitalObject;
