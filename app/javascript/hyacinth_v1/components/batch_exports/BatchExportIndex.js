import { useQuery, useMutation } from '@apollo/react-hooks';
import { Button } from 'react-bootstrap';
import PaginationBar from '@hyacinth_v1/components/shared/PaginationBar';
import React, { useState } from 'react';
import { Table } from 'react-bootstrap';
import { batchExportsQuery, deleteBatchExportMutation } from '../../graphql/batchExports';
import ContextualNavbar from '../shared/ContextualNavbar';
import GraphQLErrors from '../shared/GraphQLErrors';

function BatchExportIndex() {

  const limit = 30;
  const [offset, setOffset] = useState(0);

  const { loading: batchExportsLoading, error: batchExportsError, data: batchExportsData, refetch: batchExportsRefresh } = useQuery(batchExportsQuery, {
    variables: {
      limit,
      offset,
    },
  });

  const [deleteBatchExport, { error: deleteBatchExportError }] = useMutation(
    deleteBatchExportMutation,
  );

  if (batchExportsLoading) return (<></>);
  if (batchExportsError) {
    return (<GraphQLErrors errors={batchExportsError || deleteBatchExportError} />);
  }

  const batchExports = batchExportsData.batchExports.nodes;
  const totalBatchExports = batchExportsData.batchExports.totalCount;

  const onPageNumberClick = (page) => {
    setOffset(limit * (page - 1));
    batchExportsRefresh();
  };

  const deleteBatchExportAndRefresh = (batchExportId) => {
    // eslint-disable-next-line no-alert
    if (window.confirm(`Are you sure you want to delete Export Job ${batchExportId}?`)) {
      const variables = { input: { id: batchExportId } };
      deleteBatchExport({ variables }).then(() => batchExportsRefresh());
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
                <tr key={batchExport.id}>
                  <td>{batchExport.id}</td>
                  <td>{batchExport.searchParams}</td>
                  <td>{batchExport.user.fullName}</td>
                  <td>{batchExport.createdAt}</td>
                  <td>{batchExport.status}</td>
                  <td>{batchExport.numberOfRecordsProcessed}</td>
                  <td>
                    <Button variant="secondary">Download</Button>
                  </td>
                  <td>
                    <Button
                      variant="danger"
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
