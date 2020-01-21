import React from 'react';
import { useParams } from 'react-router-dom';
import { Row, Col } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../../layout/ContextualNavbar';
import { getTermQuery } from '../../../graphql/terms';
import GraphQLErrors from '../../ui/GraphQLErrors';
import TermBreadcrumbs from './TermBreadcrumbs';
import EditButton from '../../ui/buttons/EditButton';

function TermShow() {
  const { stringKey, uri } = useParams();

  const { loading, error, data } = useQuery(
    getTermQuery, {
      variables: { vocabularyStringKey: stringKey, uri: decodeURIComponent(uri) },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { vocabulary: { term, ...vocabulary } } = data;

  return (
    <>
      <ContextualNavbar
        title={`Term | ${term.prefLabel}`}
        rightHandLinks={[{ link: `/controlled_vocabularies/${stringKey}`, label: 'Back to Search' }]}
      />

      <TermBreadcrumbs vocabulary={vocabulary} term={term} />

      <Row as="dl">
        <Col as="dt" sm={3} md={2}>Pref Label</Col>
        <Col as="dd" sm={9} md={10}>{term.prefLabel}</Col>

        <Col as="dt" sm={3} md={2}>Alt. Labels</Col>
        <Col as="dd" sm={9} md={10}>{term.altLabels.join() || '-- None --'}</Col>

        <Col as="dt" sm={3} md={2}>Term Type</Col>
        <Col as="dd" sm={9}>{term.termType}</Col>

        <Col as="dt" sm={3} md={2}>Authority</Col>
        <Col as="dd" sm={9} md={10}>{term.authority || '-- None --'}</Col>

        <Col as="dt" sm={3} md={2}>URI</Col>
        <Col as="dd" sm={9} md={10}>{term.uri}</Col>
      </Row>

      <EditButton className="ml-2" link={`/controlled_vocabularies/${vocabulary.stringKey}/terms/${encodeURIComponent(term.uri)}/edit`}> Edit</EditButton>
    </>
  );
}

export default TermShow;
