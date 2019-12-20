import React, { useState, useEffect } from 'react';
import { Dropdown, Spinner } from 'react-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { vocabularies } from '../../../../../util/hyacinth_api';
import AddButton from '../../../buttons/AddButton';
import ControlledVocabularyNewTerm from './ControlledVocabularyNewTerm';
import ControlledVocabularyOptions from './ControlledVocabularyOptions';

const ControlledVocabularyMenu = React.forwardRef((props, ref) => {
  const {
    className,
    onChange,
    style,
    'aria-labelledby': labeledBy,
    vocabulary: vocabularyStringKey,
    close,
  } = props;

  const [loading, setLoading] = useState(true);
  const [displayNewTerm, setDisplayNewTerm] = useState(false);
  const [vocabulary, setVocabulary] = useState({});

  useEffect(() => {
    vocabularies.get(vocabularyStringKey).then((res) => {
      setVocabulary(res.data.vocabulary);
      setLoading(false);
    });
  }, []);

  const DropdownBody = displayNewTerm ? ControlledVocabularyNewTerm : ControlledVocabularyOptions;

  return (
    <div ref={ref} style={{ ...style, width: '100%' }} className={className} aria-labelledby={labeledBy}>
      { loading && <div className="m-3"><Spinner animation="border" variant="warning" /></div>}
      {
        !loading && (
          <>
            <Dropdown.Header>
              {`${vocabulary.label} Controlled Vocabulary`}
              {
                !displayNewTerm && (
                  <span className="float-right">
                    <AddButton onClick={() => setDisplayNewTerm(true)}> New Term</AddButton>
                  </span>
                )
              }
            </Dropdown.Header>
            <Dropdown.Divider />

            <DropdownBody
              vocabulary={vocabulary}
              onChange={onChange}
              displayNewTerm={setDisplayNewTerm}
              close={close}
            />
          </>
        )
      }
    </div>
  );
});

export default ControlledVocabularyMenu;
