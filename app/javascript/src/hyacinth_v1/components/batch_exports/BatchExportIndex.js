import { useMutation, useQuery } from '@apollo/react-hooks';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import produce from 'immer';
import * as moment from 'moment';
import queryString from 'query-string';
import React, { useState } from 'react';
import { Button, Card, Collapse } from 'react-bootstrap';
import { useLocation } from 'react-router-dom';
import { Can } from '../../utils/abilityContext';
import { batchExportsQuery, deleteBatchExportMutation } from '../../graphql/batchExports';
import PaginationBar from '../shared/PaginationBar';
import GraphQLErrors from '../shared/GraphQLErrors';
import ContextualNavbar from '../shared/ContextualNavbar';

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

  const onPageNumberClick = (newOffset) => {
    setOffset(newOffset);
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
      <div>
        { batchExports.length === 0 && (<p className="text-center">No Batch Exports to show. Perform a Digital Object search to create an export!</p>) }
        {
          batchExports.map(batchExport => (
            <Card key={batchExport.id} className={`mb-3 ${highlight && highlight === batchExport.id ? 'bg-light' : ''}`}>
              <Card.Header>
                {`Export ID: ${batchExport.id}`}
                <div className="float-end">
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
                  { `${batchExport.numberOfRecordsProcessed} / ${batchExport.totalRecordsToProcess}` }
                </Card.Text>
                <Card.Text className="mb-1 float-start">
                  <strong>Status: </strong>
                  {batchExport.status}
                  {' '}
                  <small>{ `(${batchExport.duration} ${batchExport.duration === 1 ? 'second' : 'seconds'})` }</small>
                </Card.Text>
                <Card.Text className="mb-0 float-end">
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
                  {
                    batchExport.status === 'SUCCESS'
                    && (
                      <>
                        <a href={batchExport.downloadPath} className="btn btn-secondary btn-sm">
                          <FontAwesomeIcon icon="download" />
                          {' '}
                          Download
                        </a>
                        {' '}
                      </>
                    )
                  }
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
                  <Card className="mt-2">
                    <Card.Body>
                      {
                        batchExport.exportErrors.map((exportError, ix) => (
                          // eslint-disable-next-line react/no-array-index-key
                          <pre className="border p-3" key={ix}><code>{exportError}</code></pre>
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
        onClick={onPageNumberClick}
      />
    </>
  );
}

export default BatchExportIndex;
