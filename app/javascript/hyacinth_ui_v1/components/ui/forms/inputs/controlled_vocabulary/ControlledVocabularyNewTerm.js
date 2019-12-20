import React from 'react';

import TermForm from '../../../../controlled_vocabularies/terms/TermForm';

function ControlledVocabularyNewTerm(props) {
  const { vocabulary, onChange, displayNewTerm } = props;

  return (
    <div className="px-3">
      <TermForm
        formType="new"
        vocabulary={vocabulary}
        submitAction={(term) => { onChange(term); displayNewTerm(false); }}
        cancelAction={() => displayNewTerm(false)}
        small
      />
    </div>
  );
}

export default ControlledVocabularyNewTerm;
