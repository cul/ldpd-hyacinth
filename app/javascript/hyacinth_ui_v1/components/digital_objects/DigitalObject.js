import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';
import produce from 'immer';

import { digitalObject } from '../../util/hyacinth_api';
import Tab from '../layout/tabs/Tab';
import Tabs from '../layout/tabs/Tabs';
import ContextualNavbar from '../layout/ContextualNavbar';
import DigitalObjectSummary from './DigitalObjectSummary';
import MetadataForm from './metadata/MetadataForm';
import Rights from './rights/Rights';
import DigitalObjectChildren from './DigitalObjectChildren';
import PageNotFound from '../layout/PageNotFound';

export default class DigitalObjectShow extends React.Component {
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
    const {
      digitalObjectData: data,
      // digitalObjectData: {
      //   uid,
      //   projects,
      //   digitalObjectType,
      // },
    } = this.state;

    const { match: { url } } = this.props;

    return (
      <>
        { data && (
          <div className="digital-object-interface">
            <ContextualNavbar
              title="Item | Really Long Title Goes Here When I Figure Out How Dynamic Fields Work"
            />

            <DigitalObjectSummary data={data} />

            <Tabs>
              <Tab to={`${url}/metadata`} name="Metadata" />
              <Tab to={`${url}/rights`} name="Rights" />
              <Tab to={`${url}/children`} name="Manage Child Assets" />
              <Tab to={`${url}/parents`} name="Parents" />
              <Tab to={`${url}/assignment`} name="Assign This" />
            </Tabs>

            <div className="m-3">
              <Switch>
                <Route
                  path="/digital_objects/:id/metadata"
                  render={props => (
                    <MetadataForm data={data} projects={data.projects} digitalObjectType={data.digitalObjectType} />
                  )}
                />
                <Route path="/digital_objects/:id/rights" component={Rights} />
                <Route
                  path="/digital_objects/:id/children"
                  render={props => (
                    <DigitalObjectChildren data={data} />
                  )}
                />
                {/* <Route path="/digital_objects/:id/enabled_dynamic_fields" component={EnabledDynamicFields} /> */}
                <Redirect exact from="/digital_objects/:id" to="/digital_objects/:id/metadata" />
                <Route component={PageNotFound} />
              </Switch>
            </div>
          </div>
        )}
      </>
    );
  }
}
