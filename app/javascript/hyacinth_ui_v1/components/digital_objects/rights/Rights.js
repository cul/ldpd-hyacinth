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

          <Route exact path="/digital_objects/:id/rights" component={RightsShow} />
          <Route path="/digital_objects/:id/rights/edit" component={RightsEdit} />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
