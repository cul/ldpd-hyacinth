import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import DigitalObjectSearch from './DigitalObjectSearch';
import DigitalObjectNew from './DigitalObjectNew';
import DigitalObjectEdit from './DigitalObjectEdit';
import DigitalObjectShow from './DigitalObjectShow';

export default class DigitalObjects extends React.PureComponent {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path="/digital-objects" component={DigitalObjectSearch} />
          <Route path="/digital-objects/new" component={DigitalObjectNew} />
          <Route path="/digital-objects/:uuid/edit" component={DigitalObjectEdit} />
          <Route path="/digital-objects/:uuid" component={DigitalObjectShow} />
          { /* When none of the above match, <PageNotFound> will be rendered */ }
          <Route component={PageNotFound} />
        </Switch>
      </div>
    );
  }
}
