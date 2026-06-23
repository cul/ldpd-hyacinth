import { QueryClient } from '@tanstack/react-query';
import ImportJobsList from '@/features/import-jobs/components/import-jobs-list';
import { getImportJobsQueryOptions } from '@/features/import-jobs/api/get-import-jobs';

export const clientLoader = (queryClient: QueryClient) => async () => {
  const query = getImportJobsQueryOptions();
  return await queryClient.ensureQueryData(query);
};

const ImportJobsIndexRoute = () => {
  return <ImportJobsList />;
};

export default ImportJobsIndexRoute;
