import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import ControlledVocabularyForm from './ControlledVocabularyForm';

class ControlledVocabularyEdit extends React.PureComponent {
  render() {
    const { match: { params: { stringKey } } } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Update Controlled Vocabulary"
          rightHandLinks={[{ link: '/controlled_vocabularies', label: 'Back to All Controlled Vocabularies' }]}
        />

        <div className="m-3">
          <ControlledVocabularyForm formType="edit" stringKey={stringKey} key={stringKey} />
        </div>
      </>
    );
  }
}

export default ControlledVocabularyEdit;
