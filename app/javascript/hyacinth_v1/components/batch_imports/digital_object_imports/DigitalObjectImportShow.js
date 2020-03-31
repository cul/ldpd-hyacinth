import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { Row, Col } from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { startCase } from 'lodash';

import ContextualNavbar from '../../shared/ContextualNavbar';
import { digitalObjectImportQuery } from '../../../graphql/digitalObjectImports';
import GraphQLErrors from '../../shared/GraphQLErrors';
import ReadableDate from '../../shared/ReadableDate';

function DigitalObjectImportShow() {
  const { batchImportId, id } = useParams();

  const { loading, error, data } = useQuery(
    digitalObjectImportQuery, {
      variables: { batchImportId, id },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const { batchImport: { originalFilename, digitalObjectImport } } = data;

  const hasErrors = digitalObjectImport.importErrors && digitalObjectImport.importErrors.length > 0;

  return (
    <>
      <ContextualNavbar
        title="Digital Object Import"
        rightHandLinks={[
          { link: `/batch_imports/${batchImportId}/digital_object_imports`, label: 'Back to All Imports' },
        ]}
      />

      <div className="px-2">
        <Row as="dl">
          <Col as="dt" sm={3}>Part of Batch Import</Col>
          <Col as="dd" sm={9}>
            <Link to={`/batch_imports/${batchImportId}`}>
              {originalFilename || id}
            </Link>
          </Col>

          <Col as="dt" sm={3}>Created At</Col>
          <Col as="dd" sm={9}><ReadableDate date={digitalObjectImport.createdAt} /></Col>

          <Col as="dt" sm={3}>Updated At</Col>
          <Col as="dd" sm={9}><ReadableDate date={digitalObjectImport.updatedAt} /></Col>

          <Col as="dt" sm={3}>Row Number</Col>
          <Col as="dd" sm={9}>{digitalObjectImport.index || '-- None --'}</Col>

          <Col as="dt" sm={3}>Status</Col>
          <Col as="dd" sm={9}>{startCase(digitalObjectImport.status)}</Col>

          <Col as="dt" sm={3}>Errors</Col>
          <Col as="dd" sm={9}>
            { hasErrors ? digitalObjectImport.importErrors.map(e => <div>{e}</div>) : '-- None --' }
          </Col>

          <Col as="dt" sm={3}>Digital Object Data</Col>
          <Col as="dd" sm={9}>
            <pre>
              <code>
                { JSON.stringify(JSON.parse(digitalObjectImport.digitalObjectData), null, 2) }
              </code>
            </pre>
          </Col>
        </Row>
      </div>
    </>
  );
}

export default DigitalObjectImportShow;
