import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';
import produce from 'immer';

import PageNotFound from '../layout/PageNotFound';
import Tab from '../ui/tabs/Tab';
import Tabs from '../ui/tabs/Tabs';
import TabBody from '../ui/tabs/TabBody';
import CoreData from './core_data/CoreData';
import FieldSet from './field_sets/FieldSet';
import PublishTarget from './publish_targets/PublishTarget';
import EnabledDynamicFields from './enabled_dynamic_fields/EnabledDynamicFields';
import hyacinthApi from '../../util/hyacinth_api';

import ContextualNavbar from '../layout/ContextualNavbar';

export default class Project extends React.Component {
  state = {
    project: null,
  }

  componentDidMount = () => {
    const { match: { params: { stringKey } } } = this.props;

    hyacinthApi.get(`/projects/${stringKey}`)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.project = res.data.project;
        }));
      });
  }

  render() {
    const { match: { url }} = this.props;
    const { project } = this.state;

    return (
      <>
        {
          project && (
            <>
              <ContextualNavbar
                title={`Project | ${project.displayLabel}`}
                rightHandLinks={[{ link: '/projects', label: 'Back to All Projects' }]}
              />

              <Tabs>
                <Tab to={`${url}/core_data`} name="Core Data" />
                <Tab to={`${url}/enabled_dynamic_fields/item`} name="Item Fields" />
                <Tab to={`${url}/enabled_dynamic_fields/asset`} name="Asset Fields" />
                <Tab to={`${url}/enabled_dynamic_fields/site`} name="Site Fields" />
                <Tab to={`${url}/permissions`} name="Permissions" />
                <Tab to={`${url}/publish_targets`} name="Publish Targets" />
                <Tab to={`${url}/field_sets`} name="Field Sets" />
              </Tabs>

              <TabBody>
                <Switch>
                  <Route path="/projects/:stringKey/core_data" component={CoreData} />
                  <Route path="/projects/:stringKey/field_sets" component={FieldSet} />
                  <Route path="/projects/:stringKey/publish_targets" component={PublishTarget} />
                  <Route path="/projects/:stringKey/enabled_dynamic_fields" component={EnabledDynamicFields} />
                  <Redirect exact from="/projects/:stringKey" to="/projects/:stringKey/core_data" />
                  <Route component={PageNotFound} />
                </Switch>
              </TabBody>
            </>
          )
        }
      </>
    );
  }
}
