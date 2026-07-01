import { useState } from 'react';
import type { ColumnDef } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { columnDefs } from '../utils/import-jobs-list-column-defs';
import { useImportJobsSuspenseQuery } from '../api/get-import-jobs';
import { ImportJobSummary } from '@/types/api';
import { DeleteImportJobModal } from './delete-import-job-modal';
import { useCurrentUser } from '@/lib/auth';
import { useTablePagination } from '@/hooks/use-table-pagination';

const ImportJobsList = () => {
  const { page, getPaginationProps } = useTablePagination();
  const importJobsQuery = useImportJobsSuspenseQuery({ page });
  const { importJobs, pagination } = importJobsQuery.data;

  const { data: currentUser } = useCurrentUser();

  const [jobToDelete, setJobToDelete] = useState<ImportJobSummary | null>(null);

  return (
    <div className="mt-4">
      <TableBuilder
        data={importJobs}
        columns={columnDefs as ColumnDef<ImportJobSummary>[]}
        pagination={getPaginationProps(pagination)}
        meta={{ currentUser: currentUser ?? undefined, onDeleteRow: setJobToDelete }}
      />

      <DeleteImportJobModal
        show={jobToDelete !== null}
        onHide={() => setJobToDelete(null)}
        importJobId={jobToDelete ? String(jobToDelete.id) : ''}
        importJobName={jobToDelete?.name ?? ''}
      />
    </div>
  );
};

export default ImportJobsList;
