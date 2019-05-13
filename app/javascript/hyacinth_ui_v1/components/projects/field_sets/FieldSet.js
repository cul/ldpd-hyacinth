import React from 'react';
import { Route, Switch } from 'react-router-dom';

import NoMatch from '../../layout/NoMatch';
import FieldSetIndex from './FieldSetIndex';
import FieldSetNew from './FieldSetNew';
import FieldSetEdit from './FieldSetEdit';

export default class FieldSet extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path="/projects/:projectStringKey/field_sets" component={FieldSetIndex} />
          <Route path="/projects/:projectStringKey/field_sets/new" component={FieldSetNew} />
          <Route path="/projects/:projectStringKey/field_sets/:id/edit" component={FieldSetEdit} />

          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={NoMatch} />
        </Switch>
      </div>
    );
  }
}
