import React, { useState, useEffect } from 'react';
import {
  Col, Row, Button, ProgressBar, Card,
} from 'react-bootstrap';
import { useQuery } from '@apollo/react-hooks';
import { Link, useParams } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { startCase } from 'lodash';

import ContextualNavbar from '../shared/ContextualNavbar';
import { batchImportQuery } from '../../graphql/batchImports';
import GraphQLErrors from '../shared/GraphQLErrors';
import ReadableDate from '../shared/ReadableDate';

function BatchImportShow() {
  const [polling, setPolling] = useState(false);
  const { id } = useParams();

  const {
    loading, error, data, startPolling, stopPolling,
  } = useQuery(
    batchImportQuery, { variables: { id } },
  );

  const flipPolling = () => {
    if (!polling) {
      startPolling(10000);
    } else {
      stopPolling();
    }
    setPolling(prevPolling => !prevPolling);
  };

  useEffect(() => {
    if (!data) { return; }

    const { batchImport: { status } } = data;
    if (polling && status !== 'IN_PROGRESS' && status !== 'PENDING') {
      flipPolling();
    }
  }, [data]);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const {
    batchImport: {
      numberOfInProgressImports: inProgress,
      numberOfPendingImports: pending,
      numberOfFailureImports: failure,
      numberOfSuccessImports: success,
      createdAt,
      downloadPath,
      fileLocation,
      withoutSuccessfulImportsDownloadPath,
      originalFilename,
      status,
      user,
      priority,
      setupErrors,
    },
  } = data;

  const total = inProgress + pending + failure + success;

  const progressBar = (variant, amount, key) => (
    <ProgressBar
      animated={polling}
      variant={variant}
      now={amount}
      key={key}
      label={amount > 0 ? amount : ''}
      max={total}
    />
  );

  return (
    <>
      <ContextualNavbar
        title={`Batch Import: ${id}`}
        rightHandLinks={[
          { link: '/batch_imports', label: 'Back to All Batch Imports' },
        ]}
      />

      <div className="px-2">
        <Row as="dl">
          <Col as="dt" sm={3}>File</Col>
          <Col as="dd" sm={9}>{originalFilename || '-- None --'}</Col>

          <Col as="dt" sm={3}>Created At</Col>
          <Col as="dd" sm={9}><ReadableDate date={createdAt} /></Col>

          <Col as="dt" sm={3}>User</Col>
          <Col as="dd" sm={9}>{user.fullName}</Col>

          <Col as="dt" sm={3}>Email</Col>
          <Col as="dd" sm={9}>{user.email}</Col>

          <Col as="dt" sm={3}>Priority</Col>
          <Col as="dd" sm={9}>{startCase(priority)}</Col>

          <Col as="dt" sm={3}>Status</Col>
          <Col as="dd" sm={9}>{startCase(status)}</Col>

          {
            fileLocation && (
              <>
                <Col as="dt" sm={3}>Downloads</Col>
                <Col as="dd" sm={9}>
                  <div>
                    <a href={downloadPath}>
                      <FontAwesomeIcon icon="download" />
                      {' '}
                      Original CSV
                    </a>
                  </div>
                  <div>
                    <a href={withoutSuccessfulImportsDownloadPath}>
                      <FontAwesomeIcon icon="download" />
                      {' '}
                      CSV File Without Successful Rows
                    </a>
                  </div>
                </Col>
              </>
            )
          }

          { setupErrors && setupErrors.length > 0 && (
            <>
              <Col as="dt" sm={3}>Setup Errors</Col>
              <Col as="dd" sm={9}>
                <Card className="mt-2">
                  <Card.Body>
                    {
                      setupErrors.map((setupError, ix) => (
                        // eslint-disable-next-line react/no-array-index-key
                        <pre className="border p-3" key={ix}><code>{setupError}</code></pre>
                      ))
                    }
                  </Card.Body>
                </Card>
              </Col>
            </>
          )}
        </Row>

        <Link className="float-end" to={`/batch_imports/${id}/digital_object_imports`}>View Details &raquo;</Link>
        <h5>
            Digital Object Imports
        </h5>

        <Row as="dl">
          <Col as="dt" sm={3}>Pending</Col>
          <Col as="dd" sm={9}>{progressBar('info', pending, 'pending')}</Col>

          <Col as="dt" sm={3}>In Progress</Col>
          <Col as="dd" sm={9}>{progressBar('warning', inProgress, 'in_progress')}</Col>

          <Col as="dt" sm={3}>Successful</Col>
          <Col as="dd" sm={9}>{progressBar('success', success, 'success')}</Col>

          <Col as="dt" sm={3}>Failed</Col>
          <Col as="dd" sm={9}>{progressBar('danger', failure, 'failure')}</Col>

          <Col as="dt" sm={3}>Total Imports</Col>
          <Col as="dd" sm={9}>
            {`${total} `}
            {
              (status === 'IN_PROGRESS' || status === 'PENDING') && (
                <Button variant="link" className="float-end" size="sm" onClick={flipPolling}>
                  {polling ? 'Stop' : 'Start'}
                  {' '}
                  Polling
                </Button>
              )
            }

          </Col>
        </Row>
      </div>
    </>
  );
}

export default BatchImportShow;
