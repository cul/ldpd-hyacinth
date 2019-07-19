import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import RightsShow from './RightsShow';
import ItemRightsForm from './ItemRightsForm';

export default class Rights extends React.PureComponent {
  render() {
    const { data, data: { digitalObjectType } } = this.props;

    return (
      <Switch>
        <Route exact path="/digital_objects/:id/rights" component={RightsShow} />
        <Route
          path="/digital_objects/:id/rights/edit"
          render={() => {
            switch (digitalObjectType) {
              case 'item':
                return <ItemRightsForm data={data} />;
              default:
                return '';
            }
          }}
        />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
