import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import DigitalObjectNew from './new/DigitalObjectNew';
import DigitalObjectNewForm from './new/DigitalObjectNewForm';
import DigitalObjectSearch from './DigitalObjectSearch';
import DigitalObject from './DigitalObject';

function DigitalObjects() {
  return (
    <div>
      <Switch>
        <Route exact path="/digital_objects" component={DigitalObjectSearch} />
        <Route path="/digital_objects/new/:projectStringKey/:digitalObjectType" component={DigitalObjectNewForm} />
        <Route path="/digital_objects/new" component={DigitalObjectNew} />
        <Route path="/digital_objects/:id" component={DigitalObject} />
        <Route component={PageNotFound} />
      </Switch>
    </div>
  );
}

export default DigitalObjects;
