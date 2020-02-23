import { useMutation, useQuery } from '@apollo/react-hooks';
import ContextualNavbar from '@hyacinth_v1/components/shared/ContextualNavbar';
import GraphQLErrors from '@hyacinth_v1/components/shared/GraphQLErrors';
import PaginationBar from '@hyacinth_v1/components/shared/PaginationBar';
import { batchExportsQuery, deleteBatchExportMutation } from '@hyacinth_v1/graphql/batchExports';
import queryString from 'query-string';
import React, { useState } from 'react';
import { Button, Card, Collapse, Row, Col } from 'react-bootstrap';
import { Can } from '@hyacinth_v1/utils/abilityContext';
import { useLocation } from 'react-router-dom';
import produce from 'immer';
import * as moment from 'moment';

function BatchExportIndex() {
  const limit = 30;
  const [offset, setOffset] = useState(0);
  const { search } = useLocation();
  const { highlight } = queryString.parse(search);
  const [expandedErrorIds, setExpandedErrorIds] = useState(new Set());
  const {
    loading, error, data, refetch,
  } = useQuery(batchExportsQuery, {
    variables: {
      limit, offset,
    },
  });

  const [deleteBatchExport, { error: deleteBatchExportError }] = useMutation(
    deleteBatchExportMutation,
  );

  if (loading) return (<></>);
  if (error) {
    return (<GraphQLErrors errors={error || deleteBatchExportError} />);
  }

  const batchExports = data.batchExports.nodes;
  const totalBatchExports = data.batchExports.totalCount;

  const onPageNumberClick = (page) => {
    setOffset(limit * (page - 1));
    refetch();
  };

  const deleteBatchExportAndRefresh = (batchExportId) => {
    // eslint-disable-next-line no-alert
    if (window.confirm(`Are you sure you want to delete Export Job ${batchExportId}?`)) {
      const variables = { input: { id: batchExportId } };
      deleteBatchExport({ variables }).then(() => refetch());
    }
  };

  const toggleExpandedError = (batchExportId) => {
    setExpandedErrorIds(
      produce(expandedErrorIds, (draft) => {
        if (draft.has(batchExportId)) {
          draft.delete(batchExportId);
        } else {
          draft.add(batchExportId);
        }
      }),
    );
  };

  return (
    <>
      <ContextualNavbar
        title="Batch Exports"
      />
      <PaginationBar
        offset={offset}
        limit={limit}
        totalItems={totalBatchExports}
        onPageNumberClick={onPageNumberClick}
      />
      <div>
        {
          batchExports.map(batchExport => (
            <Card key={batchExport.id} className={`mb-3 ${highlight && highlight === batchExport.id ? 'bg-light' : ''}`}>
              <Card.Header>
                {`Export ID: ${batchExport.id}`}
                <div className="float-right">
                  {moment(batchExport.createdAt).format('MMMM Do YYYY, h:mm:ss a')}
                </div>
              </Card.Header>
              <Card.Body>
                <Can I="manage" a="all">
                  {/* Only want to show user field when viewing as admin */}
                  <Card.Text className="mb-1">
                    <strong>User: </strong>
                    {batchExport.user.fullName}
                  </Card.Text>
                </Can>
                <Card.Text className="mb-1">
                  <strong>Search Params: </strong>
                  <code>
                    {batchExport.searchParams}
                  </code>
                </Card.Text>
                <Card.Text className="mb-1">
                  <strong>Records Processed: </strong>
                  {
                    `${batchExport.numberOfRecordsProcessed} / ${batchExport.totalRecordsToProcess}`
                  }
                </Card.Text>
                <Card.Text className="mb-1 float-left">
                  <strong>Status: </strong>
                  {batchExport.status}
                </Card.Text>
                <Card.Text className="mb-1 float-right">
                  {
                    batchExport.exportErrors.length > 0
                      && (
                        <>
                          <Button
                            variant="secondary"
                            size="sm"
                            onClick={() => { toggleExpandedError(batchExport.id); }}
                          >
                            {expandedErrorIds.has(batchExport.id) ? 'Hide Errors' : 'Show Errors'}
                          </Button>
                          {' '}
                        </>
                      )
                  }
                  <Button variant="secondary" size="sm">Download</Button>
                  {' '}
                  <Button
                    variant="danger"
                    size="sm"
                    onClick={(e) => {
                      e.preventDefault(); deleteBatchExportAndRefresh(batchExport.id);
                    }}
                  >
                      Delete
                  </Button>
                </Card.Text>
                <div className="clearfix" />
                <Collapse in={expandedErrorIds.has(batchExport.id)}>
                  <Card className="mt-1">
                    <Card.Body>
                      {
                        batchExport.exportErrors.map((exportError, ix) => (
                          // eslint-disable-next-line react/no-array-index-key
                          <pre key={ix}><code>{exportError}</code></pre>
                        ))
                      }
                    </Card.Body>
                  </Card>
                </Collapse>
              </Card.Body>
            </Card>
          ))
        }
      </div>
      <PaginationBar
        offset={offset}
        limit={limit}
        totalItems={totalBatchExports}
        onPageNumberClick={onPageNumberClick}
      />
    </>
  );
}

export default BatchExportIndex;
