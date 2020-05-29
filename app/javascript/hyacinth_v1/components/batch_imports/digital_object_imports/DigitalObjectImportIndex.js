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
              <Badge variant="secondary">{amount}</Badge>
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
  const [statusFilter, setStatusFilter] = useState('all');

  const {
    loading, error, data, refetch,
  } = useQuery(
    digitalObjectImportsQuery, {
      variables: {
        id,
        limit,
        offset,
        status: statusFilter === 'all' ? null : statusFilter,
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
      numberOfPendingImports: pending,
      numberOfFailureImports: failure,
      numberOfSuccessImports: success,
      numberOfInProgressImports: inProgress,
      digitalObjectImports: { totalCount, nodes: digitalObjectImports },
    },
  } = data;

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

        <Nav variant="tabs" defaultActiveKey="all" activeKey={statusFilter} onSelect={onTabClick}>
          <StatusNavItem eventKey="all" amount={pending + failure + success + inProgress} />
          <StatusNavItem eventKey="pending" amount={pending} />
          <StatusNavItem eventKey="in_progress" amount={inProgress} />
          <StatusNavItem eventKey="success" amount={success} />
          <StatusNavItem eventKey="failure" amount={failure} />
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
                digitalObjectImports.map(digitalObjectImport => (
                  <tr key={digitalObjectImport.id}>
                    <td>
                      <Link to={`/batch_imports/${id}/digital_object_imports/${digitalObjectImport.id}`}>
                        {digitalObjectImport.id}
                      </Link>
                    </td>
                    <td>{digitalObjectImport.index}</td>
                    <td>{startCase(digitalObjectImport.status)}</td>
                    <td><ReadableDate date={digitalObjectImport.createdAt} /></td>
                    <td><ReadableDate date={digitalObjectImport.updatedAt} /></td>
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
