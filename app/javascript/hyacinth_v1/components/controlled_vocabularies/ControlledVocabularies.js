import React from 'react';
import { Route, Switch } from 'react-router-dom';

import PageNotFound from '../layout/PageNotFound';
import ControlledVocabularyIndex from './ControlledVocabularyIndex';
import ControlledVocabularyNew from './ControlledVocabularyNew';
import ControlledVocabularyShow from './ControlledVocabularyShow';
import ControlledVocabularyEdit from './ControlledVocabularyEdit';

import Terms from './terms/Terms';
import ProtectedRoute from '../ProtectedRoute';

function ControlledVocabularies() {
  return (
    <Switch>
      <ProtectedRoute
        exact
        path="/controlled_vocabularies"
        component={ControlledVocabularyIndex}
        requiredAbility={{ action: 'update', subject: 'Vocabulary' }}
      />

      <ProtectedRoute
        exact
        path="/controlled_vocabularies/new"
        component={ControlledVocabularyNew}
        requiredAbility={{ action: 'create', subject: 'Vocabulary' }}
      />

      <ProtectedRoute
        path="/controlled_vocabularies/:stringKey/edit"
        component={ControlledVocabularyEdit}
        requiredAbility={params => (
          { action: 'update', subject: 'Vocabulary', stringKey: params.stringKey }
        )}
      />

      <Route path="/controlled_vocabularies/:stringKey/terms" component={Terms} />

      <ProtectedRoute
        path="/controlled_vocabularies/:stringKey"
        component={ControlledVocabularyShow}
        requiredAbility={params => (
          { action: 'update', subject: 'Vocabulary', stringKey: params.stringKey }
        )}
      />

      { /* When none of the above match, <PageNotFound> will be rendered */ }
      <Route component={PageNotFound} />
    </Switch>
  );
}

export default ControlledVocabularies;