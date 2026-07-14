import { useState } from 'react';
import type { ColumnDef } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { ConfirmDeleteModal } from '@/components/ui/modals/confirm-delete-modal/confirm-delete-modal';
import { columnDefs } from '../utils/export-jobs-list-column-defs';
import { useExportJobsSuspenseQuery } from '../api/get-export-jobs';
import { useDeleteExportJob } from '../api/delete-export-job';
import { ExportJob } from '@/types/api';
import { useNotifications } from '@/stores/notifications-store';
import { useTablePagination } from '@/hooks/use-table-pagination';

const ExportJobsList = () => {
  const { page, getPaginationProps } = useTablePagination();
  const exportJobsQuery = useExportJobsSuspenseQuery({ page });
  const { exportJobs, pagination } = exportJobsQuery.data;

  const addNotification = useNotifications((state) => state.addNotification);

  const [jobToDelete, setJobToDelete] = useState<ExportJob | null>(null);

  const deleteExportJobMutation = useDeleteExportJob({
    mutationConfig: {
      onSuccess: () => {
        addNotification({
          type: 'success',
          title: 'Export job deleted',
          message: `Export Job #${jobToDelete?.id} was successfully deleted.`,
        });
        setJobToDelete(null);
      },
    },
  });

  const handleDismiss = () => {
    if (deleteExportJobMutation.isPending) return;
    deleteExportJobMutation.reset();
    setJobToDelete(null);
  };

  const handleConfirmDelete = () => {
    if (!jobToDelete) return;
    deleteExportJobMutation.mutate({ exportJobId: String(jobToDelete.id) });
  };

  const apiError = deleteExportJobMutation.error?.response?.errors?.base?.[0];

  return (
    <div className="mt-4">
      <TableBuilder
        data={exportJobs}
        columns={columnDefs as ColumnDef<ExportJob>[]}
        pagination={getPaginationProps(pagination)}
        meta={{ onDeleteRow: setJobToDelete }}
      />

      <ConfirmDeleteModal
        show={jobToDelete !== null}
        onHide={handleDismiss}
        onConfirm={handleConfirmDelete}
        title="Delete Export Job"
        resourceName={jobToDelete ? `Export Job #${jobToDelete.id}` : ''}
        isPending={deleteExportJobMutation.isPending}
        errorMessage={apiError}
      />
    </div>
  );
};

export default ExportJobsList;
