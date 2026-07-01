import { QueryClient } from '@tanstack/react-query';
import { useSearchParams } from 'react-router';
import type { ColumnDef, PaginationState, Updater } from '@tanstack/react-table';
import { getExportJobsQueryOptions } from '@/features/export-jobs/api/get-export-jobs';
import { useExportJobsSuspenseQuery } from '@/features/export-jobs/api/get-export-jobs';
import { columnDefs } from '@/features/export-jobs/utils/export-jobs-list-column-defs';
import TableBuilder from '@/components/ui/table-builder/table-builder';
import { ExportJob } from '@/types/api';

export const clientLoader =
  (queryClient: QueryClient) =>
  async ({ request }: any) => {
    const page = Number(new URL(request.url).searchParams.get('page')) || 1;
    await queryClient.ensureQueryData(getExportJobsQueryOptions(page));
  };

const ExportJobsIndexRoute = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const page = Number(searchParams.get('page')) || 1;

  const exportJobsQuery = useExportJobsSuspenseQuery({ page });
  const { exportJobs, pagination } = exportJobsQuery.data;

  // TODO: This is the same logic as in import-jobs-list.tsx; might work well as a custom hook
  const paginationState: PaginationState = {
    pageIndex: page - 1,
    pageSize: pagination.perPage,
  };

  // TODO: This is the same logic as in import-jobs-list.tsx; might work well as a custom hook
  const handlePaginationChange = (updater: Updater<PaginationState>) => {
    const next = typeof updater === 'function' ? updater(paginationState) : updater;
    setSearchParams((prev) => {
      prev.set('page', String(next.pageIndex + 1));
      return prev;
    });
  };

  return (
    <>
      <h2>CSV Exports</h2>

      <TableBuilder
        data={exportJobs}
        columns={columnDefs as ColumnDef<ExportJob>[]}
        pagination={{
          state: paginationState,
          onPaginationChange: handlePaginationChange,
          rowCount: pagination.totalCount,
        }}
      />
    </>
  );
};

export default ExportJobsIndexRoute;
