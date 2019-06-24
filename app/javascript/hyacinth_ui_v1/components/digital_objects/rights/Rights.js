import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import RightsEdit from './RightsEdit';
import RightsShow from './RightsShow';

import ItemRightsEdit from './ItemRightsEdit';
import AssetRightsEdit from './AssetRightsEdit';
import { dynamicFieldData1 } from '../mock/dynamicFieldData';

export default class Rights extends React.PureComponent {
  render() {
    return (
      <div>
        <Switch>
          {/* Mockups for Rights Module */}
          <Route
            exact
            path="/digital_objects/test1/rights/edit"
            render={() => (
              <ItemRightsEdit
                dynamicFieldData={dynamicFieldData1}
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

          <Route exact path="/digital_objects/:uuid/rights" component={RightsShow} />
          <Route path="/digital_objects/:uuid/rights/edit" component={RightsEdit} />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
