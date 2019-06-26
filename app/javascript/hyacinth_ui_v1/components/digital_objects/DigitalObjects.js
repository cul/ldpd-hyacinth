import React from 'react';
import { Route, Switch } from 'react-router-dom';
import queryString from 'query-string';

import PageNotFound from '../layout/PageNotFound';
import DigitalObjectSearch from './DigitalObjectSearch';
import DigitalObjectNew from './DigitalObjectNew';
import DigitalObject from './DigitalObject';
import ItemRightsEdit from './rights/ItemRightsEdit';
import AssetRightsEdit from './rights/AssetRightsEdit';
import AggregatorNew from './new/AggregatorNew';
import { cul_q83bk3jc9s, cul_vdncjsxn7t, cul_bnzs7h45zq } from './mock/dynamicFieldData';
import Rights from './rights/Rights';

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
              <ItemRightsEdit
                id="cul:q83bk3jc9s"
                key="cul:q83bk3jc9s"
                dynamicFieldData={cul_q83bk3jc9s}
              />
            )}
          />

          <Route
            exact
            path="/digital_objects/cul_vdncjsxn7t/rights/edit"
            render={() => (
              <ItemRightsEdit
                id="cul:vdncjsxn7t"
                key="cul:vdncjsxn7t"
                dynamicFieldData={cul_vdncjsxn7t}
              />
            )}
          />

          <Route
            exact
            path="/digital_objects/cul_bnzs7h45zq/rights/edit"
            render={() => (
              <ItemRightsEdit
                id="cul:bnzs7h45zq"
                key="cul:bnzs7h45zq"
                dynamicFieldData={cul_bnzs7h45zq}
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

          <Route path="/digital_objects/:id" component={DigitalObject} />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
