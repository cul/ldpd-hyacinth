import { useMutation, useQuery } from '@apollo/react-hooks';
import ContextualNavbar from '@hyacinth_v1/components/shared/ContextualNavbar';
import GraphQLErrors from '@hyacinth_v1/components/shared/GraphQLErrors';
import PaginationBar from '@hyacinth_v1/components/shared/PaginationBar';
import { batchExportsQuery, deleteBatchExportMutation } from '@hyacinth_v1/graphql/batchExports';
import queryString from 'query-string';
import React, { useState } from 'react';
import { Button, Table } from 'react-bootstrap';
import { useLocation } from 'react-router-dom';

function BatchExportIndex() {
  const limit = 30;
  const [offset, setOffset] = useState(0);
  const { search } = useLocation();
  const { highlight } = queryString.parse(search);

  const { loading, error, data, refetch } = useQuery(batchExportsQuery, {
    variables: {
      limit,
      offset,
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
            <th>Records Processed</th>
            <th>Download</th>
            <th>Delete?</th>
          </tr>
        </thead>
        <tbody>
          {
            (
              batchExports.map(batchExport => (
                <tr key={batchExport.id} className={highlight && batchExport.id === highlight ? 'table-info' : ''}>
                  <td>{batchExport.id}</td>
                  <td>{batchExport.searchParams}</td>
                  <td>{batchExport.user.fullName}</td>
                  <td>{batchExport.createdAt}</td>
                  <td>{batchExport.status}</td>
                  <td>{`${batchExport.numberOfRecordsProcessed} / ${batchExport.totalRecordsToProcess}`}</td>
                  {
                    // TODO: Maybe display exportErrors errors here
                  }
                  <td>
                    <Button variant="secondary" size="sm">Download</Button>
                  </td>
                  <td>
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
