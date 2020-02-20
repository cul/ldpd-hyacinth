import { useQuery } from '@apollo/react-hooks';
import PaginationBar from '@hyacinth_v1/components/shared/PaginationBar';
import React, { useState } from 'react';
import { Table } from 'react-bootstrap';
import { batchExportsQuery } from '../../graphql/batchExports';
import ContextualNavbar from '../shared/ContextualNavbar';
import GraphQLErrors from '../shared/GraphQLErrors';

function BatchExportIndex() {

  const limit = 30;
  const [offset, setOffset] = useState(0);

  const { loading, error, data, refetch } = useQuery(batchExportsQuery, {
    variables: {
      limit,
      offset,
    },
  });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const batchExports = data.batchExports.nodes;
  const totalBatchExports = data.batchExports.totalCount;

  const onPageNumberClick = (page) => {
    setOffset(limit * (page - 1));
    refetch();
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
                    <a href="#">Download</a>
                  </td>
                  <td>
                    <a href="#">Delete</a>
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
