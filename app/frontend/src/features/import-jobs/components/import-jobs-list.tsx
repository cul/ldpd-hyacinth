import { useState } from 'react';
import { useSearchParams } from 'react-router';
import type { ColumnDef, PaginationState } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { columnDefs } from '../utils/import-jobs-list-column-defs';
import { useImportJobsSuspenseQuery } from '../api/get-import-jobs';
import { ImportJob } from '@/types/api';
// import { DeleteImportJobModal } from './delete-import-job-modal';

const ImportJobsList = () => {
  const [searchParams] = useSearchParams();
  const page = Number(searchParams.get('page')) || 1;

  const importJobsQuery = useImportJobsSuspenseQuery({ page });
  const importJobs = importJobsQuery.data.importJobs;
  const paginationData = importJobsQuery.data.pagination;
  // console.log('importJobs:', importJobsQuery.data);

  // const [pagination, setPagination] = useState<PaginationState>({
  //   pageIndex: 0,
  //   pageSize: paginationData.perPage,
  // });

  return (
    <>
      {/* <DeleteImportJobModal /> */}

      {/* TODO: Modify TableBuilder to handle server-side pagination */}
      <TableBuilder data={importJobs} columns={columnDefs as ColumnDef<ImportJob>[]} />
    </>
  );
};

export default ImportJobsList;
