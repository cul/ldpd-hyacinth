import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import ControlledVocabularyIndex from './ControlledVocabularyIndex';
import ControlledVocabularyNew from './ControlledVocabularyNew';
import ControlledVocabularyEdit from './ControlledVocabularyEdit';
import ProtectedRoute from '../ProtectedRoute';

export default class ControlledVocabularies extends React.PureComponent {
  render() {
    return (
      <Switch>
        <ProtectedRoute
          exact
          path="/controlled_vocabularies"
          component={ControlledVocabularyIndex}
          requiredAbility={{ action: 'index', subject: 'ControlledVocabulary' }}
        />

        <ProtectedRoute
          exact
          path="/controlled_vocabularies/new"
          component={ControlledVocabularyNew}
          requiredAbility={{ action: 'create', subject: 'ControlledVocabulary' }}
        />

        <ProtectedRoute
          path="/controlled_vocabularies/:stringKey/edit"
          component={ControlledVocabularyEdit}
          requiredAbility={params => (
            { action: 'update', subject: 'ControlledVocabulary', id: params.id }
          )}
        />

        { /* When none of the above match, <PageNotFound> will be rendered */ }
        <Route component={PageNotFound} />
      </Switch>
    );
  }
}
