import React from 'react';
import { Row, Col, Button } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { useParams } from 'react-router-dom';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../layout/ContextualNavbar';
import TermIndex from './terms/TermIndex';
import EditButton from '../ui/buttons/EditButton';
import GraphQLErrors from '../ui/GraphQLErrors';
import { getVocabularyQuery } from '../../graphql/vocabularies';

function ControlledVocabularyShow() {
  const { stringKey } = useParams();

  const { loading, error, data } = useQuery(
    getVocabularyQuery, {
      variables: { stringKey },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { vocabulary } = data;

  return (
    <>
      <ContextualNavbar
        title={`Controlled Vocabulary | ${vocabulary.label}`}
        rightHandLinks={[{ link: '/controlled_vocabularies', label: 'Back to All Controlled Vocabularies' }]}
      />
      <div className="m-2">
        <h3>
          Vocabulary
          <EditButton className="ml-2" link={`/controlled_vocabularies/${vocabulary.stringKey}/edit`} />
        </h3>

        <Row as="dl">
          <Col as="dt" sm={4} md={3}>String Key</Col>
          <Col as="dd" sm={8} md={8}>{vocabulary.stringKey}</Col>

          <Col as="dt" sm={4} md={3}>Label</Col>
          <Col as="dd" sm={8} md={8}>{vocabulary.label}</Col>

          <Col as="dt" sm={4} md={3}>Locked</Col>
          <Col as="dd" sm={8} md={8}>{vocabulary.locked ? 'Yes' : 'No'}</Col>

          <Col as="dt" sm={4} md={3}>Custom Fields</Col>
          <Col as="dd" sm={8} md={8}>{vocabulary.customFieldDefinitions.map(v => v.label).join(', ') || '-- None --'}</Col>
        </Row>
      </div>

      <hr />
      <h3>
        Terms
        <LinkContainer to={`/controlled_vocabularies/${vocabulary.stringKey}/terms/new`}>
          <Button variant="outline-primary" className="float-right">
            <FontAwesomeIcon icon="plus" />
            {' Add New Term'}
          </Button>
        </LinkContainer>
      </h3>

      <TermIndex vocabularyStringKey={stringKey} />
    </>
  );
}

export default ControlledVocabularyShow;
