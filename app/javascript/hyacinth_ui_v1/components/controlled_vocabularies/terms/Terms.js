import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../../layout/PageNotFound';
import TermIndex from './TermIndex';
import TermEdit from './TermEdit';
import TermNew from './TermNew';

// import ControlledVocabularyNew from './ControlledVocabularyNew';
// import ControlledVocabularyEdit from './ControlledVocabularyEdit';
import ProtectedRoute from '../../ProtectedRoute';

export default class Terms extends React.PureComponent {
  render() {
    return (
      <Switch>
        {/* <ProtectedRoute
          exact
          path="/controlled_vocabularies/:stringKey/terms"
          component={TermIndex}
          requiredAbility={{ action: 'index', subject: 'ControlledVocabulary' }}
        /> */}

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

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
