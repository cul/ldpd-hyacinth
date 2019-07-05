import React from 'react';
import { Route, Switch, Redirect } from 'react-router-dom';
import queryString from 'query-string';

import PageNotFound from '../layout/PageNotFound';
import DigitalObjectSearch from './DigitalObjectSearch';
import DigitalObjectNew from './DigitalObjectNew';
import ItemRightsForm from './rights/ItemRightsForm';
import AssetRightsEdit from './rights/AssetRightsEdit';
import AggregatorNew from './new/AggregatorNew';
import { cul_q83bk3jc9s, cul_vdncjsxn7t, cul_bnzs7h45zq } from './mock/dynamicFieldData';
import Rights from './rights/Rights';
import Metadata from './metadata/Metadata';
import Children from './children/Children';
import PreservePublish from './preserve_publish/PreservePublish';

export default class DigitalObjects extends React.PureComponent {
  render() {
    return (
      <div>
        <Switch>
          {/* Mockups for Rights Module */}
          <Route
            exact
            path="/digital_objects/cul_q83bk3jc9s/rights/edit"
            render={() => (
              <ItemRightsForm
                id="cul:q83bk3jc9s"
                key="cul:q83bk3jc9s"
                data={{ dynamicFieldData: cul_q83bk3jc9s }}
              />
            )}
          />

          <Route
            exact
            path="/digital_objects/cul_vdncjsxn7t/rights/edit"
            render={() => (
              <ItemRightsForm
                id="cul:vdncjsxn7t"
                key="cul:vdncjsxn7t"
                data={{ dynamicFieldData: cul_vdncjsxn7t }}
              />
            )}
          />

          <Route
            exact
            path="/digital_objects/cul_bnzs7h45zq/rights/edit"
            render={() => (
              <ItemRightsForm
                id="cul:bnzs7h45zq"
                key="cul:bnzs7h45zq"
                data={{ dynamicFieldData: cul_bnzs7h45zq }}
              />
            )}
          />

          <Route
            exact
            path="/digital_objects/asset1/rights/edit"
            render={() => (
              <AssetRightsEdit
                dynamicFieldData={{}}
              />
            )}
          />

          {/*  End of Rights Module Mockupds */}

          <Route exact path="/digital_objects" component={DigitalObjectSearch} />

          <Route
            path="/digital_objects/new"
            render={(props) => {
              const { location: { search } } = props;
              const { project, parent, digitalObjectType } = queryString.parse(search);

              if (parent && digitalObjectType === 'asset') {
                return <></>;
              }

              if (project && digitalObjectType !== 'asset') {
                return (
                  <AggregatorNew
                    digitalObjectType={digitalObjectType}
                    project={project}
                  />
                );
              }

              return <DigitalObjectNew />;
            }}
          />

          <Route path="/digital_objects/:id/metadata" component={Metadata} />
          <Route path="/digital_objects/:id/rights" component={Rights} />
          <Route path="/digital_objects/:id/children" component={Children} />
          <Route path="/digital_objects/:id/preserve_publish" component={PreservePublish} />

          <Redirect exact from="/digital_objects/:id" to="/digital_objects/:id/metadata" />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
