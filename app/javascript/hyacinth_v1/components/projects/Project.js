import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';

import PageNotFound from '../shared/PageNotFound';
import CoreData from './core_data/CoreData';
import FieldSet from './field_sets/FieldSet';
import Permissions from './permissions/Permissions';
import PublishTarget from './publish_targets/PublishTarget';
import EnabledDynamicFields from './enabled_dynamic_fields/EnabledDynamicFields';

function Project() {
  return (
    <Switch>
      <Route path="/projects/:stringKey/core_data" component={CoreData} />
      <Route path="/projects/:stringKey/field_sets" component={FieldSet} />
      <Route path="/projects/:stringKey/permissions" component={Permissions} />
      <Route path="/projects/:stringKey/publish_targets" component={PublishTarget} />
      <Route path="/projects/:stringKey/enabled_dynamic_fields" component={EnabledDynamicFields} />
      <Redirect exact from="/projects/:stringKey" to="/projects/:stringKey/core_data" />
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default Project;
