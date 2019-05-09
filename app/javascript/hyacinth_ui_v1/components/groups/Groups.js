import React from 'react';
import { Link, Route, Switch } from 'react-router-dom';

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';
import NoMatch from 'hyacinth_ui_v1/components/layout/NoMatch';
import GroupIndex from 'hyacinth_ui_v1/components/groups/GroupIndex';
import GroupNew from 'hyacinth_ui_v1/components/groups/GroupNew';
import GroupEdit from 'hyacinth_ui_v1/components/groups/GroupEdit';

export default class Groups extends React.Component {
  render() {
    return (
      <div>
        <Switch>
          <Route exact path="/groups" component={GroupIndex} />
          <Route path="/groups/new" component={GroupNew} />
          <Route path="/groups/:string_key/edit" component={GroupEdit} />
          { /* When none of the above match, <NoMatch> will be rendered */ }
          <Route component={NoMatch} />
        </Switch>
      </div>
    );
  }
}
