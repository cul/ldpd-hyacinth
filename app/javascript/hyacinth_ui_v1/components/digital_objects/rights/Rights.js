import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import RightsEdit from './RightsEdit';
import RightsShow from './RightsShow';

export default class Rights extends React.PureComponent {
  render() {
    const { data } = this.props;

    return (
      <div>
        <Switch>

          <Route exact path="/digital_objects/:id/rights" component={RightsShow} />
          <Route path="/digital_objects/:id/rights/edit" render={props => <RightsEdit data={data} />} />

          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
