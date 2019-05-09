import React from 'react';
import { Route, Switch } from 'react-router-dom';

import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch';
import FieldSetIndex from './FieldSetIndex';
import FieldSetNew from './FieldSetNew';
import FieldSetEdit from './FieldSetEdit';

export default class FieldSet extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path={`${this.props.match.path}`} component={FieldSetIndex} />
          <Route path={`${this.props.match.path}/new`} component={FieldSetNew} />
          {/* <Route exact path="/projects/:string_key" component={ProjectShow} /> */}
          <Route path={`${this.props.match.path}/:id/edit`} component={FieldSetEdit} />

          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={NoMatch} />
        </Switch>
      </div>
    );
  }
}
