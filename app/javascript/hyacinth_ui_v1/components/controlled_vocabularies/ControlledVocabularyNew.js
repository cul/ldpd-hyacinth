import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import ControlledVocabularyForm from './ControlledVocabularyForm';

class DynamicFieldGroupNew extends React.PureComponent {
  render() {
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
}

export default DynamicFieldGroupNew;
