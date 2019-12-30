import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import RightsShow from './RightsShow';
import ItemRightsForm from './ItemRightsForm';

export default class Rights extends React.PureComponent {
  render() {
    const { match: { params: { id } } } = this.props;

    return (
      <Switch>
        <Route exact path="/digital_objects/:id/rights" component={RightsShow} />
        <Route
          path="/digital_objects/:id/rights/edit"
          render={() => {
            switch ('item') {
              case 'item':
                return <ItemRightsForm />;
              default:
                return '';
            }
          }}
        />

        { /* TODO: Change above route to:
        <ProtectedRoute
          path="/digital_objects/:id/rights/edit"
          render={() => {
            switch ('item') {
              case 'item':
                return <ItemRightsForm />;
              default:
                return '';
            }
          }}
          requiredAbility={{ action: 'assess_rights', subject: 'Project', subject_id: project.stringKey }}
        />
        */ }

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
