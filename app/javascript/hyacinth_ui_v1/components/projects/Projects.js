import React from 'react'
import { Link, Route, Switch, Redirect } from "react-router-dom";

import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch'
import ProjectIndex from 'hyacinth_ui_v1/components/projects/ProjectIndex'
import ProjectNew from 'hyacinth_ui_v1/components/projects/ProjectNew'
import CoreData from 'hyacinth_ui_v1/components/projects/core_data/CoreData'
import FieldSet from 'hyacinth_ui_v1/components/projects/field_sets/FieldSet'
import ProjectLayout from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectLayout'
import ProjectTabs from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectTabs/ProjectTabs'
import ProjectTab from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectTabs/ProjectTab/ProjectTab'

export default class Projects extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path="/projects" component={ProjectIndex} />
          <Route path="/projects/new" component={ProjectNew} />

          <Route path="/projects/:string_key" render={props =>
            <ProjectLayout stringKey={props.match.params.string_key}>
              <ProjectTabs>
                <ProjectTab to={props.match.url + '/core_data'} name="Core Data"/>
                <ProjectTab to={props.match.url + "/enabled_dynamic_fields/item"} name="Item Fields"/>
                <ProjectTab to={props.match.url + "/enabled_dynamic_fields/asset"} name="Asset Fields"/>
                <ProjectTab to={props.match.url + "/enabled_dynamic_fields/site"} name="Site Fields"/>
                <ProjectTab to={props.match.url + '/permissions'} name="Permissions"/>
                <ProjectTab to={props.match.url + '/publish_targets'} name="Publish Targets"/>
                <ProjectTab to={props.match.url + "/field_sets"} name="Field Sets"/>
              </ProjectTabs>

              <div className="m-3">
                <Switch>
                  <Route path="/projects/:string_key/core_data" component={CoreData} />
                  <Route path="/projects/:string_key/field_sets" component={FieldSet} />
                  <Redirect exact from="/projects/:string_key" to="/projects/:string_key/core_data" />
                  <Route component={NoMatch} />
                </Switch>
              </div>
            </ProjectLayout>
          }/>

          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={NoMatch} />
        </Switch>
      </div>
    )
  }
}
