import { useQuery } from '@apollo/react-hooks';
import PaginationBar from '@hyacinth_v1/components/shared/PaginationBar';
import React, { useState } from 'react';
import { Table } from 'react-bootstrap';
import { exportJobsQuery } from '../../graphql/exportJobs';
import ContextualNavbar from '../shared/ContextualNavbar';
import GraphQLErrors from '../shared/GraphQLErrors';

function ExportJobIndex() {

  const limit = 30;
  const [offset, setOffset] = useState(0);

  const { loading, error, data, refetch } = useQuery(exportJobsQuery, {
    variables: {
      limit,
      offset,
    },
  });

  if (loading) return (<></>);
  if (error) return (<GraphQLErrors errors={error} />);

  const exportJobs = data.exportJobs.nodes;
  const totalExportJobs = data.exportJobs.totalCount;

  const onPageNumberClick = (page) => {
    setOffset(limit * (page - 1));
    refetch();
  };

  return (
    <>
      <ContextualNavbar
        title="Export Jobs"
      />
      <PaginationBar
        offset={offset}
        limit={limit}
        totalItems={totalExportJobs}
        onPageNumberClick={onPageNumberClick}
      />
      <Table hover>
        <thead>
          <tr>
            <th>Export Job ID</th>
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
              exportJobs.map(exportJob => (
                <tr key={exportJob.id}>
                  <td>{exportJob.id}</td>
                  <td>{exportJob.searchParams}</td>
                  <td>{exportJob.user.fullName}</td>
                  <td>{exportJob.createdAt}</td>
                  <td>{exportJob.status}</td>
                  <td>{exportJob.numberOfRecordsProcessed}</td>
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
        totalItems={totalExportJobs}
        onPageNumberClick={onPageNumberClick}
      />
    </>
  );
}

export default ExportJobIndex;
