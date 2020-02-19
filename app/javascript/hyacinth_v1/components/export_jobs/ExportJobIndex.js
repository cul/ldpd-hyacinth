import { useQuery } from '@apollo/react-hooks';
import PaginationBar from '@hyacinth_v1/components/shared/PaginationBar';
import React from 'react';
import { Table } from 'react-bootstrap';
import { exportJobsQuery } from '../../graphql/exportJobs';
import ContextualNavbar from '../shared/ContextualNavbar';
import GraphQLErrors from '../shared/GraphQLErrors';

function ExportJobIndex() {
  const perPage = 2;
  const page = 1;
  const limit = 2;
  const offset = 0;

  const { loading, error, data } = useQuery(exportJobsQuery, {
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
    console.log("Clicked on page: " + page);
  };

  return (
    <>
      <ContextualNavbar
        title="Field Export Profiles"
        rightHandLinks={[{ link: '/field_export_profiles/new', label: 'New Field Export Profile' }]}
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
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          {
            (
              exportJobs.map(exportJob => (
                <tr key={exportJob.id}>
                  <td>
                    {exportJob.id}
                  </td>
                </tr>
              ))
            )
          }
        </tbody>
      </Table>
    </>
  );
}

export default ExportJobIndex;
