import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';

import NoMatch from '../layout/NoMatch';
import ProjectLayout from '../../hoc/ProjectLayout/ProjectLayout';
import ProjectTabs from '../../hoc/ProjectLayout/ProjectTabs/ProjectTabs';
import ProjectTab from '../../hoc/ProjectLayout/ProjectTabs/ProjectTab/ProjectTab';
import ability from '../../util/ability';
import ProjectIndex from './ProjectIndex';
import ProjectNew from './ProjectNew';
import CoreData from './core_data/CoreData';
import FieldSet from './field_sets/FieldSet';
import PublishTarget from './publish_targets/PublishTarget';

export default class Projects extends React.Component {
  render() {
    return (
      <Switch>
        <Route exact path="/projects" component={ProjectIndex} />

        <Route path="/projects/new" component={ability.can('create', 'Project') ? ProjectNew : NoMatch} />

        <Route
          path="/projects/:stringKey"
          render={props => (
            <ProjectLayout stringKey={props.match.params.stringKey}>
              <ProjectTabs>
                <ProjectTab to={`${props.match.url}/core_data`} name="Core Data" />
                <ProjectTab to={`${props.match.url}/enabled_dynamic_fields/item`} name="Item Fields" />
                <ProjectTab to={`${props.match.url}/enabled_dynamic_fields/asset`} name="Asset Fields" />
                <ProjectTab to={`${props.match.url}/enabled_dynamic_fields/site`} name="Site Fields" />
                <ProjectTab to={`${props.match.url}/permissions`} name="Permissions" />
                <ProjectTab to={`${props.match.url}/publish_targets`} name="Publish Targets" />
                <ProjectTab to={`${props.match.url}/field_sets`} name="Field Sets" />
              </ProjectTabs>

              <div className="m-3">
                <Switch>
                  <Route path="/projects/:stringKey/core_data" component={CoreData} />
                  <Route path="/projects/:stringKey/field_sets" component={FieldSet} />
                  <Route path="/projects/:stringKey/publish_targets" component={PublishTarget} />
                  <Redirect exact from="/projects/:stringKey" to="/projects/:stringKey/core_data" />
                  <Route component={NoMatch} />
                </Switch>
              </div>
            </ProjectLayout>
          )}
        />

        { /* When none of the above match, <NoMatch> will be rendered */ }
        <Route component={NoMatch} />
      </Switch>
    );
  }
}
