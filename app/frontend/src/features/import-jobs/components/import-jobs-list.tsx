import { useState } from 'react';
import { useSearchParams } from 'react-router';
import type { ColumnDef, PaginationState, Updater } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { columnDefs } from '../utils/import-jobs-list-column-defs';
import { useImportJobsSuspenseQuery } from '../api/get-import-jobs';
import { ImportJobSummary } from '@/types/api';
import { DeleteImportJobModal } from './delete-import-job-modal';

const ImportJobsList = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const page = Number(searchParams.get('page')) || 1;

  const importJobsQuery = useImportJobsSuspenseQuery({ page });
  const { importJobs, pagination } = importJobsQuery.data;

  const [jobToDelete, setJobToDelete] = useState<ImportJobSummary | null>(null);

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
      <TableBuilder
        data={importJobs}
        columns={columnDefs as ColumnDef<ImportJobSummary>[]}
        pagination={{
          state: paginationState,
          onPaginationChange: handlePaginationChange,
          rowCount: pagination.totalCount,
        }}
        meta={{ onDeleteRow: setJobToDelete }}
      />

      <DeleteImportJobModal
        show={jobToDelete !== null}
        onHide={() => setJobToDelete(null)}
        importJobId={jobToDelete ? String(jobToDelete.id) : ''}
        importJobName={jobToDelete?.name ?? ''}
      />
    </>
  );
};

export default ImportJobsList;
