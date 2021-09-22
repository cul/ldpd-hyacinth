import React from 'react';
import { useParams } from 'react-router-dom';
import { Row, Col } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';

import ContextualNavbar from '../../shared/ContextualNavbar';
import { getTermQuery } from '../../../graphql/terms';
import GraphQLErrors from '../../shared/GraphQLErrors';
import TermBreadcrumbs from './TermBreadcrumbs';
import EditButton from '../../shared/buttons/EditButton';
import { Can } from '../../../utils/abilityContext';

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

      <div className="m-2">
        <Row as="dl">
          <Col as="dt" sm={3} md={2}>Pref Label</Col>
          <Col as="dd" sm={9} md={10}>{term.prefLabel}</Col>

          <Col as="dt" sm={3} md={2}>Alt. Labels</Col>
          <Col as="dd" sm={9} md={10}>{term.altLabels.join(', ') || '-- None --'}</Col>

          <Col as="dt" sm={3} md={2}>Term Type</Col>
          <Col as="dd" sm={9}>{term.termType}</Col>

          <Col as="dt" sm={3} md={2}>Authority</Col>
          <Col as="dd" sm={9} md={10}>{term.authority || '-- None --'}</Col>

          <Col as="dt" sm={3} md={2}>URI</Col>
          <Col as="dd" sm={9} md={10}>{term.uri}</Col>

          {
            vocabulary.customFieldDefinitions.map((definition) => {
              const { fieldKey, label } = definition;

              const customField = term.customFields.find((element) => element.field === fieldKey);
              const value = customField ? customField.value : '-- None --';

              return (
                <React.Fragment key={fieldKey}>
                  <Col as="dt" sm={3} md={2}>{label}</Col>
                  <Col as="dd" sm={9} md={10}>{value || '-- None --'}</Col>
                </React.Fragment>
              );
            })
          }
        </Row>

        <Can I="update" a="Term">
          <EditButton
            className="float-end"
            size={null}
            link={`/controlled_vocabularies/${vocabulary.stringKey}/terms/${encodeURIComponent(term.uri)}/edit`}
            disabled={vocabulary.locked}
          >
            {' Edit'}
          </EditButton>
        </Can>
      </div>
    </>
  );
}

export default TermShow;
