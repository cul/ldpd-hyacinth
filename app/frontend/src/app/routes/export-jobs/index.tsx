import { QueryClient } from '@tanstack/react-query';
import { LoaderFunctionArgs } from 'react-router';
import { getExportJobsQueryOptions } from '@/features/export-jobs/api/get-export-jobs';
import ExportJobsList from '@/features/export-jobs/components/export-jobs-list';

export const clientLoader =
  (queryClient: QueryClient) =>
  async ({ request }: LoaderFunctionArgs) => {
    const page = Number(new URL(request.url).searchParams.get('page')) || 1;
    await queryClient.ensureQueryData(getExportJobsQueryOptions(page));
  };

const ExportJobsIndexRoute = () => {
  return (
    <>
      <h2>CSV Exports</h2>

      <ExportJobsList />
    </>
  );
};

export default ExportJobsIndexRoute;
