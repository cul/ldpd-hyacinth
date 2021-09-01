import React, { useState } from 'react';
import { useQuery } from '@apollo/react-hooks';
import { Link, useParams } from 'react-router-dom';
import {
  Col, Row, Nav, Table, Badge,
} from 'react-bootstrap';
import { startCase } from 'lodash';

import ContextualNavbar from '../../shared/ContextualNavbar';
import GraphQLErrors from '../../shared/GraphQLErrors';
import { digitalObjectImportsQuery } from '../../../graphql/digitalObjectImports';
import ReadableDate from '../../shared/ReadableDate';
import PaginationBar from '../../shared/PaginationBar';

function StatusNavItem({ eventKey, amount }) {
  return (
    <Nav.Item>
      <Nav.Link eventKey={eventKey} disabled={amount === 0}>
        {startCase(eventKey)}
        {
          amount > 0 && (
            <>
              {' '}
              <Badge bg="secondary">{amount}</Badge>
            </>
          )
        }
      </Nav.Link>
    </Nav.Item>
  );
}

function DigitalObjectImportIndex() {
  const limit = 100;
  const { id } = useParams();

  const [offset, setOffset] = useState(0);
  const [statusFilter, setStatusFilter] = useState('ALL');

  const {
    loading, error, data, refetch,
  } = useQuery(
    digitalObjectImportsQuery, {
      variables: {
        id,
        limit,
        offset,
        status: statusFilter === 'ALL' ? null : statusFilter,
      },
    },
  );

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const onPageNumberClick = (newOffset) => {
    setOffset(newOffset);
    refetch();
  };

  const onTabClick = (status) => {
    setOffset(0);
    setStatusFilter(status);
    refetch();
  };

  const {
    batchImport: {
      status,
      originalFilename,
      numberOfPendingImports: pendingCount,
      numberOfCreationFailureImports: creationFailureCount,
      numberOfUpdateFailureImports: updateFailureCount,
      numberOfPersistFailureImports: persistFailureCount,
      numberOfPublishFailureImports: publishFailureCount,
      numberOfSuccessImports: successCount,
      numberOfInProgressImports: inProgressCount,
      digitalObjectImports: { totalCount, nodes: digitalObjectImports },
    },
  } = data;

  const failureCount = creationFailureCount + updateFailureCount + persistFailureCount + publishFailureCount;

  return (
    <>
      <ContextualNavbar
        title="Digital Object Imports"
        rightHandLinks={[
          { link: `/batch_imports/${id}`, label: 'Back to Batch Import' },
        ]}
      />

      <div className="m-2">
        <Row as="dl">
          <Col as="dt" sm={3}>Imports Part of Batch Import</Col>
          <Col as="dd" sm={9}>
            <Link to={`/batch_imports/${id}`}>
              {originalFilename || id}
            </Link>
          </Col>

          <Col as="dt" sm={3}>Status of Batch Import</Col>
          <Col as="dd" sm={9}>{status}</Col>
        </Row>

        <Nav variant="tabs" defaultActiveKey="ALL" activeKey={statusFilter} onSelect={onTabClick}>
          <StatusNavItem eventKey="ALL" amount={pendingCount + failureCount + successCount + inProgressCount} />
          <StatusNavItem eventKey="PENDING" amount={pendingCount} />
          <StatusNavItem eventKey="IN_PROGRESS" amount={inProgressCount} />
          <StatusNavItem eventKey="SUCCESS" amount={successCount} />
          <StatusNavItem eventKey="CREATION_FAILURE" amount={creationFailureCount} />
          <StatusNavItem eventKey="UPDATE_FAILURE" amount={updateFailureCount} />
          <StatusNavItem eventKey="PERSIST_FAILURE" amount={persistFailureCount} />
          <StatusNavItem eventKey="PUBLISH_FAILURE" amount={publishFailureCount} />
        </Nav>

        <div className="m-2">
          <Table striped hover responsive size="sm">
            <thead>
              <tr>
                <th style={{ borderTop: 'none' }}>id</th>
                <th style={{ borderTop: 'none' }}>CSV Row</th>
                <th style={{ borderTop: 'none' }}>Status</th>
                <th style={{ borderTop: 'none' }}>Created At</th>
                <th style={{ borderTop: 'none' }}>Updated At</th>
              </tr>
            </thead>
            <tbody>
              {
                digitalObjectImports.map((digitalObjectImport) => (
                  <tr key={digitalObjectImport.id}>
                    <td>
                      <Link to={`/batch_imports/${id}/digital_object_imports/${digitalObjectImport.id}`}>
                        {digitalObjectImport.id}
                      </Link>
                    </td>
                    <td>{digitalObjectImport.index}</td>
                    <td>{startCase(digitalObjectImport.status)}</td>
                    <td><ReadableDate isoDate={digitalObjectImport.createdAt} /></td>
                    <td><ReadableDate isoDate={digitalObjectImport.updatedAt} /></td>
                  </tr>
                ))
              }
            </tbody>
          </Table>

          <PaginationBar
            limit={limit}
            offset={offset}
            totalItems={totalCount}
            onClick={onPageNumberClick}
          />
        </div>
      </div>
    </>
  );
}

export default DigitalObjectImportIndex;
