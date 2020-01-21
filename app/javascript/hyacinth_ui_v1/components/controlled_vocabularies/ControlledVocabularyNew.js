import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import ControlledVocabularyForm from './ControlledVocabularyForm';

function ControlledVocabularyNew() {
  return (
    <>
      <ContextualNavbar
        title="Create Controlled Vocabulary"
        rightHandLinks={[{ link: '/controlled_vocabularies', label: 'Back to All Controlled Vocabularies' }]}
      />

      <ControlledVocabularyForm formType="new" />
    </>
  );
}

export default ControlledVocabularyNew;
