import React, { useState, useEffect } from 'react';
import {
  Form, Row, Col, Button, Table, InputGroup,
} from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import { useParams, Link } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../shared/ContextualNavbar';
import SearchButton from '../shared/buttons/SearchButton';
import GraphQLErrors from '../shared/GraphQLErrors';
import { getTermsQuery } from '../../graphql/terms';
import { Can } from '../../utils/abilityContext';
import PaginationBar from '../shared/PaginationBar';
import FontAwesomeIcon from '../../utils/lazyFontAwesome';

const limit = 10;

function ControlledVocabularyShow() {
  const { stringKey } = useParams();

  const [searchTerms, setSearchTerms] = useState('');
  const [offset, setOffset] = useState(0);
  const [totalTerms, setTotalTerms] = useState(0);

  const {
    loading, error, data, refetch,
  } = useQuery(
    getTermsQuery, {
      variables: { vocabularyStringKey: stringKey, offset: 0, limit },
    },
  );

  useEffect(() => {
    if (!data) { return; }
    const { vocabulary: { terms: { totalCount } } } = data;
    setTotalTerms(totalCount);
  }, [data]);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const onSearchHandler = (event) => {
    event.preventDefault();

    if (searchTerms.length >= 3 || searchTerms === '') {
      setOffset(0);
      refetch({ offset: 0, searchParams: { searchTerms } });
    }
  };

  const onPageNumberClick = (newOffset) => {
    setOffset(newOffset);
    refetch({ offset: newOffset, searchParams: { searchTerms } });
  };

  const { vocabulary, vocabulary: { terms: { nodes: terms } } } = data;

  return (
    <>
      <ContextualNavbar
        title={`Controlled Vocabulary | ${vocabulary.label}`}
        rightHandLinks={[{ link: '/controlled_vocabularies', label: 'Back to All Controlled Vocabularies' }]}
      />
      <div className="m-2">
        <h3>
          Vocabulary
          <Can I="edit" of={{ subjectType: 'Vocabulary', stringKey: vocabulary.stringKey }}>
            <LinkContainer to={`/controlled_vocabularies/${vocabulary.stringKey}/edit`}>
              <Button size="sm" variant="outline-primary" className="float-end">
                <FontAwesomeIcon icon="pen" />
                {' Edit Vocabulary'}
              </Button>
            </LinkContainer>
          </Can>
        </h3>

        <Row as="dl">
          <Col as="dt" sm={4} md={3}>String Key</Col>
          <Col as="dd" sm={8} md={8}>{vocabulary.stringKey}</Col>

          <Col as="dt" sm={4} md={3}>Label</Col>
          <Col as="dd" sm={8} md={8}>{vocabulary.label}</Col>

          <Col as="dt" sm={4} md={3}>Locked</Col>
          <Col as="dd" sm={8} md={8}>{vocabulary.locked ? 'Yes' : 'No'}</Col>

          <Col as="dt" sm={4} md={3}>Custom Fields</Col>
          <Col as="dd" sm={8} md={8}>{vocabulary.customFieldDefinitions.map((v) => v.label).join(', ') || '-- None --'}</Col>
        </Row>
      </div>

      <hr />
      <h3>
        Terms
        <Can I="update" a="Term">
          <LinkContainer to={`/controlled_vocabularies/${vocabulary.stringKey}/terms/new`}>
            <Button size="sm" variant="outline-primary" className="float-end" disabled={vocabulary.locked}>
              <FontAwesomeIcon icon="plus" />
              {' Add New Term'}
            </Button>
          </LinkContainer>
        </Can>
      </h3>

      <div className="m-2">
        <Form className="term-search-form" onSubmit={onSearchHandler}>
          <InputGroup>
            <Form.Control
              type="text"
              value={searchTerms}
              onChange={(e) => setSearchTerms(e.target.value)}
              placeholder="Search for terms..."
            />
            <SearchButton sm="auto" onClick={onSearchHandler} />
          </InputGroup>
        </Form>

        { searchTerms.length > 0 && searchTerms.length < 3 && <Form.Text className="text-muted pl-2">Query must be at least three characters.</Form.Text> }

        <Table hover responsive>
          <thead>
            <tr>
              <th>Pref Label</th>
              <th>Type</th>
              <th>Authority</th>
              <th>URI</th>
            </tr>
          </thead>
          <tbody>
            {
              terms.length > 0 ? (
                terms.map((term) => (
                  <tr key={term.id}>
                    <td><Link to={`/controlled_vocabularies/${stringKey}/terms/${encodeURIComponent(term.uri)}`}>{term.prefLabel}</Link></td>
                    <td>{term.termType}</td>
                    <td>{term.authority}</td>
                    <td>{term.uri}</td>
                  </tr>
                ))
              ) : <tr><td colSpan={4}>No Results</td></tr>
            }
          </tbody>
        </Table>

        <PaginationBar
          limit={limit}
          offset={offset}
          totalItems={totalTerms}
          onClick={onPageNumberClick}
        />
      </div>
    </>
  );
}

export default ControlledVocabularyShow;
