import React, { useState } from 'react';
import { Card, Button } from 'react-bootstrap';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { startCase } from 'lodash';

import { Can } from '@hyacinth_v1/utils/abilityContext';
import ContextualNavbar from '../shared/ContextualNavbar';
import GraphQLErrors from '../shared/GraphQLErrors';
import PaginationBar from '../shared/PaginationBar';
import ReadableDate from '../shared/ReadableDate';
import { batchImportsQuery, updateBatchImportMutation, deleteBatchImportMutation } from '../../graphql/batchImports';

function BatchImportIndex() {
  const limit = 10;
  const [offset, setOffset] = useState(0);

  const {
    loading, error, data, refetch,
  } = useQuery(batchImportsQuery, { variables: { limit, offset } });

  const [updateBatchImport, { error: updateError }] = useMutation(updateBatchImportMutation);
  const [deleteBatchImport, { error: deleteError }] = useMutation(deleteBatchImportMutation);

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const onPageNumberClick = (newOffset) => {
    setOffset(newOffset);
    refetch();
  };

  const onCancel = (id) => {
    // eslint-disable-next-line no-alert
    if (window.confirm(`Are you sure you want to cancel Import Job ${id}?`)) {
      const variables = { input: { id, cancelled: true } };
      updateBatchImport({ variables }).then(refetch);
    }
  };

  const onDelete = (id) => {
    // eslint-disable-next-line no-alert
    if (window.confirm(`Are you sure you want to delete Export Job ${id}?`)) {
      const variables = { input: { id } };
      deleteBatchImport({ variables }).then(refetch);
    }
  };

  const { batchImports: { nodes: batchImports, totalCount: totalBatchImports } } = data;

  return (
    <>
      <ContextualNavbar
        title="Batch Imports"
        rightHandLinks={[
          { link: 'batch_imports/new', label: 'New Batch Import' },
        ]}
      />
      <GraphQLErrors errors={updateError || deleteError} />
      { batchImports.length === 0 && (<p className="text-center">No Batch Imports have been created.</p>) }
      {
        batchImports.map(batchImport => (
          <Card key={batchImport.id} className="mb-3">
            <Card.Header>
              {`Import ID: ${batchImport.id}`}
              {batchImport.setupErrors && batchImport.setupErrors.length > 0 && (
                <>
                  &nbsp;-&nbsp;
                  <strong className="text-danger">Setup errors encountered. View import details for more info.</strong>
                </>
              )}
              <div className="float-right">
                <ReadableDate date={batchImport.createdAt} />
              </div>
            </Card.Header>
            <Card.Body>
              <Can I="manage" a="all">
                {/* Only want to show user field when viewing as admin */}
                <Card.Text className="mb-1">
                  <strong>User: </strong>
                  {batchImport.user.fullName}
                </Card.Text>
              </Can>
              <Card.Text className="mb-1">
                <strong>File Uploaded: </strong>
                {batchImport.originalFilename ? batchImport.originalFilename : '-- None --'}
              </Card.Text>
              <Card.Text className="mb-1">
                <strong>Priority: </strong>
                {startCase(batchImport.priority)}
              </Card.Text>
              <Card.Text className="mb-1 float-left">
                <strong>Status: </strong>
                {startCase(batchImport.status)}
              </Card.Text>
              <Card.Text className="mb-0 float-right">
                <Button variant="danger" size="sm" onClick={() => onDelete(batchImport.id)}>
                  Delete
                </Button>
                {' '}
                {
                  !batchImport.cancelled && !batchImport.status.startsWith('complete') && (
                    <Button variant="secondary" size="sm" onClick={() => onCancel(batchImport.id)}>
                      Cancel Import
                    </Button>
                  )
                }
                {' '}
                <a href={`batch_imports/${batchImport.id}`} className="btn btn-primary btn-sm">
                  View
                </a>
              </Card.Text>
            </Card.Body>
          </Card>
        ))
      }
      <PaginationBar
        offset={offset}
        limit={limit}
        totalItems={totalBatchImports}
        onClick={onPageNumberClick}
      />
    </>
  );
}

export default BatchImportIndex;
