import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Dropdown, Button, Form, Spinner,
} from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { produce } from 'immer';

import TermOption from './TermOption';
import { getTermsQuery } from '../../../../../graphql/terms';
import GraphQLErrors from '../../../GraphQLErrors';
import AddButton from '../../../buttons/AddButton';
import TermForm from '../../../../controlled_vocabularies/terms/TermForm';

const limit = 10;

function TermOptions({ vocabularyStringKey, onChange, close }) {
  const [query, setQuery] = useState('');
  const [totalTerms, setTotalTerms] = useState(0);
  const [infoExpandedFor, setInfoExpandedFor] = useState('');
  const [displayNewTerm, setDisplayNewTerm] = useState(false);

  const {
    loading, error, data, refetch, fetchMore,
  } = useQuery(getTermsQuery, {
    variables: {
      vocabularyStringKey, limit, offset: 0, searchParams: { query: query.length >= 3 ? query : '' },
    },
    onCompleted: res => setTotalTerms(res.vocabulary.terms.totalCount),
  });

  if (error) return (<GraphQLErrors errors={error} />);
  if (loading) return (<div className="m-3"><Spinner animation="border" variant="warning" /></div>);

  const onSearchHandler = (event) => {
    const { target: { value } } = event;

    setQuery(value);

    if (value.length >= 3) { refetch(); }
  };

  const onCollapseHandler = (id) => {
    setInfoExpandedFor(id === infoExpandedFor ? '' : id);
  };

  const { vocabulary: { terms: { nodes: terms }, ...vocabulary } } = data;

  const onMoreHandler = () => {
    if (terms.length >= totalTerms) return;

    fetchMore({
      variables: { offset: terms.length },
      updateQuery: (prev, { fetchMoreResult }) => {
        if (!fetchMoreResult) return prev;
        return produce(prev, (draft) => {
          draft.vocabulary.terms.nodes = [
            ...prev.vocabulary.terms.nodes,
            ...fetchMoreResult.vocabulary.terms.nodes,
          ];
        });
      },
    });
  };

  const onSelectHandler = (uri) => {
    const { prefLabel, uri: selectedURI } = terms.find(o => o.uri === uri);

    onChange({ pref_label: prefLabel, uri: selectedURI });
  };

  return (
    <>
      <Dropdown.Header>
        {`${vocabulary.label} Controlled Vocabulary`}
        {
          !displayNewTerm && (
            <span className="float-end">
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
              onCancel={() => setDisplayNewTerm(false)}
            />
          </div>
        ) : (
          <div style={{ maxHeight: '350px', overflowY: 'auto' }}>
            <Form.Control
              size="sm"
              autoFocus
              className="mx-3 my-2 w-auto"
              placeholder="Type to search..."
              onChange={onSearchHandler}
              value={query}
            />

            <ul className="list-unstyled">
              {
                terms.map(term => (
                  <TermOption
                    key={term.id}
                    term={term}
                    onSelect={() => onSelectHandler(term.uri)}
                    onCollapseToggle={() => onCollapseHandler(term.id)}
                    expanded={infoExpandedFor === term.id}
                  />
                ))
              }
            </ul>

            {
              totalTerms > terms.length
                && <Button variant="link" onClick={onMoreHandler} className="float-end py-0">More...</Button>
            }
          </div>
        )
      }
    </>
  );
}

TermOptions.propTypes = {
  vocabularyStringKey: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
};

export default TermOptions;
