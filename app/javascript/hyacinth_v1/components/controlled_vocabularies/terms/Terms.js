import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import TermEdit from './TermEdit';
import TermNew from './TermNew';
import TermShow from './TermShow';
import ProtectedRoute from '../../ProtectedRoute';

export default class Terms extends React.PureComponent {
  render() {
    return (
      <Switch>
        <ProtectedRoute
          exact
          path="/controlled_vocabularies/:stringKey/terms/new"
          component={TermNew}
          requiredAbility={{ action: 'create', subject: 'Term' }}
        />

        <ProtectedRoute
          path="/controlled_vocabularies/:stringKey/terms/:uri/edit"
          component={TermEdit}
          requiredAbility={params => (
            { action: 'update', subject: 'Term', id: params.id }
          )}
        />

        <ProtectedRoute
          path="/controlled_vocabularies/:stringKey/terms/:uri"
          component={TermShow}
          requiredAbility={params => (
            { action: 'read', subject: 'Term', id: params.id }
          )}
        />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
