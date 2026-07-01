import { QueryClient } from '@tanstack/react-query';
import type { ColumnDef } from '@tanstack/react-table';
import { getExportJobsQueryOptions } from '@/features/export-jobs/api/get-export-jobs';
import { useExportJobsSuspenseQuery } from '@/features/export-jobs/api/get-export-jobs';
import { columnDefs } from '@/features/export-jobs/utils/export-jobs-list-column-defs';
import TableBuilder from '@/components/ui/table-builder/table-builder';
import { ExportJob } from '@/types/api';
import { useTablePagination } from '@/hooks/use-table-pagination';

export const clientLoader =
  (queryClient: QueryClient) =>
  async ({ request }: any) => {
    const page = Number(new URL(request.url).searchParams.get('page')) || 1;
    await queryClient.ensureQueryData(getExportJobsQueryOptions(page));
  };

const ExportJobsIndexRoute = () => {
  const { page, getPaginationProps } = useTablePagination();
  const exportJobsQuery = useExportJobsSuspenseQuery({ page });
  const { exportJobs, pagination } = exportJobsQuery.data;

  // const { data: currentUser } = useCurrentUser();

  // const [jobToDelete, setJobToDelete] = useState<ExportJob | null>(null);

  return (
    <>
      <h2>CSV Exports</h2>

      <TableBuilder
        data={exportJobs}
        columns={columnDefs as ColumnDef<ExportJob>[]}
        pagination={getPaginationProps(pagination)}
      />
    </>
  );
};

export default ExportJobsIndexRoute;
