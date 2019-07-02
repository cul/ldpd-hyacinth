import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';
import produce from 'immer';

import { digitalObject } from '../../util/hyacinth_api';
import Tab from '../ui/tabs/Tab';
import Tabs from '../ui/tabs/Tabs';
import TabBody from '../ui/tabs/TabBody';
import ContextualNavbar from '../layout/ContextualNavbar';
import DigitalObjectSummary from './DigitalObjectSummary';
import MetadataForm from './metadata/MetadataForm';
import Rights from './rights/Rights';
import DigitalObjectChildren from './DigitalObjectChildren';
import PageNotFound from '../layout/PageNotFound';

export default class DigitalObject extends React.Component {
  state = {
    digitalObjectData: null,
  };

  componentDidMount() {
    const { match: { params: { id } } } = this.props;

    digitalObject.get(id)
      .then((res) => {
        this.setState(produce((draft) => {
          draft.digitalObjectData = res.data.digitalObject;
        }));
      });
  }

  render() {
    const { digitalObjectData: data } = this.state;

    const { match: { url } } = this.props;

    return (
      <>
        { data && (
          <div className="digital-object-interface">
            <ContextualNavbar
              title={`Item | ${(data) ? data.dynamicFieldData.title[0].titleSortPortion : ''}`}
            />

            <DigitalObjectSummary data={data} />

            <Tabs>
              <Tab to={`${url}/metadata`} name="Metadata" />
              <Tab to={`${url}/rights`} name="Rights" />

              {
                (data.digitalObjectType === 'item') && (
                  <Tab to={`${url}/children`} name="Manage Child Assets" />
                )
              }

              {
                (data.digitalObjectType === 'asset') && (
                  <Tab to={`${url}/parents`} name="Parents" />
                )
              }

              <Tab to={`${url}/assignment`} name="Assign This" />
              <Tab to={`${url}/preserve_publish`} name="Preserve/Publish" />
            </Tabs>

            <TabBody>
              <Switch>
                <Route
                  path="/digital_objects/:id/metadata"
                  render={() => <MetadataForm data={data} formType="edit"/> }
                />

                <Route
                  path="/digital_objects/:id/rights"
                  render={() => <Rights data={data} />}
                />
                <Route
                  path="/digital_objects/:id/children"
                  render={() => <DigitalObjectChildren data={data} /> }
                />
                {/* <Route path="/digital_objects/:id/enabled_dynamic_fields" component={EnabledDynamicFields} /> */}
                <Redirect exact from="/digital_objects/:id" to="/digital_objects/:id/metadata" />
                <Route component={PageNotFound} />
              </Switch>
            </TabBody>
          </div>
        )}
      </>
    );
  }
}
