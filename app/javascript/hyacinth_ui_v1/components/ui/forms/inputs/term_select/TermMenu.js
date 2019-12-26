import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { Dropdown, Spinner } from 'react-bootstrap';

import { vocabularies } from '../../../../../util/hyacinth_api';
import AddButton from '../../../buttons/AddButton';
import TermForm from '../../../../controlled_vocabularies/terms/TermForm';

import TermOptions from './TermOptions';

const TermMenu = React.forwardRef((props, ref) => {
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

            {
              displayNewTerm ? (
                <div className="px-3">
                  <TermForm
                    small
                    formType="new"
                    vocabulary={vocabulary}
                    submitAction={(term) => { onChange(term); setDisplayNewTerm(false); close(); }}
                    cancelAction={() => setDisplayNewTerm(false)}
                  />
                </div>
              ) : <TermOptions vocabulary={vocabulary.stringKey} onChange={onChange} />
            }
          </>
        )
      }
    </div>
  );
});

TermMenu.propTypes = {
  vocabulary: PropTypes.string.isRequired,
  value: PropTypes.shape({
    prefLabel: PropTypes.string,
    uri: PropTypes.string,
  }).isRequired,
  onChange: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
  className: PropTypes.string.isRequired,
  'aria-labelledby': PropTypes.string.isRequired,
};

export default TermMenu;
