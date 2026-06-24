import { useSearchParams } from 'react-router';
import type { ColumnDef, PaginationState, Updater } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { columnDefs } from '../utils/import-jobs-list-column-defs';
import { useImportJobsSuspenseQuery } from '../api/get-import-jobs';
import { ImportJobSummary } from '@/types/api';

const ImportJobsList = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const page = Number(searchParams.get('page')) || 1;

  const importJobsQuery = useImportJobsSuspenseQuery({ page });
  const { importJobs, pagination } = importJobsQuery.data;

  // TanStack is zero-based; URL is one-based.
  const paginationState: PaginationState = {
    pageIndex: page - 1,
    pageSize: pagination.perPage,
  };

  const handlePaginationChange = (updater: Updater<PaginationState>) => {
    const next = typeof updater === 'function' ? updater(paginationState) : updater;
    setSearchParams((prev) => {
      prev.set('page', String(next.pageIndex + 1));
      return prev;
    });
  };

  return (
    <>
      {/* <DeleteImportJobModal /> */}

      <TableBuilder
        data={importJobs}
        columns={columnDefs as ColumnDef<ImportJobSummary>[]}
        pagination={{
          state: paginationState,
          onPaginationChange: handlePaginationChange,
          rowCount: pagination.totalCount,
        }}
      />
    </>
  );
};

export default ImportJobsList;
