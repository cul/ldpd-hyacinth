import { useState } from 'react';
import type { ColumnDef } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { ConfirmDeleteModal } from '@/components/ui/modals/confirm-delete-modal/confirm-delete-modal';
import { columnDefs } from '../utils/import-jobs-list-column-defs';
import { useImportJobsSuspenseQuery } from '../api/get-import-jobs';
import { useDeleteImportJob } from '../api/delete-import-job';
import { ImportJobSummary } from '@/types/api';
import { useCurrentUser } from '@/lib/auth';
import { useNotifications } from '@/stores/notifications-store';
import { useTablePagination } from '@/hooks/use-table-pagination';

const ImportJobsList = () => {
  const { page, getPaginationProps } = useTablePagination();
  const importJobsQuery = useImportJobsSuspenseQuery({ page });
  const { importJobs, pagination } = importJobsQuery.data;

  const { data: currentUser } = useCurrentUser();
  const addNotification = useNotifications((state) => state.addNotification);

  const [jobToDelete, setJobToDelete] = useState<ImportJobSummary | null>(null);

  const deleteImportJobMutation = useDeleteImportJob({
    mutationConfig: {
      onSuccess: () => {
        addNotification({
          type: 'success',
          title: 'Import job deleted',
          message: `"${jobToDelete?.name}" was successfully deleted.`,
        });
        setJobToDelete(null);
      },
    },
  });

  const handleDismiss = () => {
    if (deleteImportJobMutation.isPending) return;
    deleteImportJobMutation.reset();
    setJobToDelete(null);
  };

  const handleConfirmDelete = () => {
    if (!jobToDelete) return;
    deleteImportJobMutation.mutate({ importJobId: String(jobToDelete.id) });
  };

  const apiError = deleteImportJobMutation.error?.response?.errors?.base?.[0];

  return (
    <div className="mt-4">
      <TableBuilder
        data={importJobs}
        columns={columnDefs as ColumnDef<ImportJobSummary>[]}
        pagination={getPaginationProps(pagination)}
        meta={{ currentUser: currentUser ?? undefined, onDeleteRow: setJobToDelete }}
      />

      <ConfirmDeleteModal
        show={jobToDelete !== null}
        onHide={handleDismiss}
        onConfirm={handleConfirmDelete}
        title="Delete Import Job"
        resourceName={jobToDelete?.name ?? ''}
        isPending={deleteImportJobMutation.isPending}
        errorMessage={apiError}
      />
    </div>
  );
};

export default ImportJobsList;
