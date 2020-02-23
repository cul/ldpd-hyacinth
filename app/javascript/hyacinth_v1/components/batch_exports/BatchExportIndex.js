import { useMutation, useQuery } from '@apollo/react-hooks';
import ContextualNavbar from '@hyacinth_v1/components/shared/ContextualNavbar';
import GraphQLErrors from '@hyacinth_v1/components/shared/GraphQLErrors';
import PaginationBar from '@hyacinth_v1/components/shared/PaginationBar';
import { batchExportsQuery, deleteBatchExportMutation } from '@hyacinth_v1/graphql/batchExports';
import queryString from 'query-string';
import React, { useState } from 'react';
import { Button, Collapse, Table } from 'react-bootstrap';
import { useLocation } from 'react-router-dom';
import produce from 'immer';

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
      <Table hover>
        <thead>
          <tr>
            <th>Batch Export ID</th>
            <th>Search Params</th>
            <th>User</th>
            <th>Created</th>
            <th>Status</th>
            <th>Progress</th>
            <th className="text-center">Errors</th>
            <th className="text-center">Actions</th>
          </tr>
        </thead>
        <tbody>
          {
            (
              batchExports.map(batchExport => (
                <React.Fragment key={batchExport.id}>
                  <tr className={highlight && batchExport.id === highlight ? 'table-info' : ''}>
                    <td>{batchExport.id}</td>
                    <td>{batchExport.searchParams}</td>
                    <td>{batchExport.user.fullName}</td>
                    <td>{batchExport.createdAt}</td>
                    <td>{batchExport.status}</td>
                    <td>{`${batchExport.numberOfRecordsProcessed} / ${batchExport.totalRecordsToProcess}`}</td>
                    <td className="text-center">
                      {
                        batchExport.exportErrors.length === 0
                          ? <>None</>
                          : (
                            <Button
                              variant="secondary"
                              size="sm"
                              onClick={() => { toggleExpandedError(batchExport.id); }}
                            >
                              View Errors
                            </Button>
                          )
                      }
                    </td>
                    <td className="text-center">
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
                    </td>
                  </tr>
                  {
                    batchExport.exportErrors.length > 0
                    && (
                      <tr key={`errors-for-${batchExport.id}`}>
                        <td colSpan="8">
                          <Collapse in={expandedErrorIds.has(batchExport.id)}>
                            <div>
                              {
                                batchExport.exportErrors.map((exportError, ix) => (
                                  // eslint-disable-next-line react/no-array-index-key
                                  <pre key={ix}><code>{exportError}</code></pre>
                                ))
                              }
                            </div>
                          </Collapse>
                        </td>
                      </tr>
                    )
                  }
                </React.Fragment>
              ))
            )
          }
        </tbody>
      </Table>
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
