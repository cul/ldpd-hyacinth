import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import ControlledVocabularyForm from './ControlledVocabularyForm';

class ControlledVocabularyEdit extends React.PureComponent {
  render() {
    const { match: { params: { stringKey } } } = this.props;

    return (
      <div className="m-3">
        <ContextualNavbar
          title="Update Controlled Vocabulary"
          rightHandLinks={[{ link: '/controlled_vocabularies', label: 'Back to Controlled Vocabulary' }]}
        />

        <ControlledVocabularyForm formType="edit" stringKey={stringKey} key={stringKey} />
      </div>
    );
  }
}

export default ControlledVocabularyEdit;
