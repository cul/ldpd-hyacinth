import { QueryClient } from '@tanstack/react-query';
import { useParams, LoaderFunctionArgs } from 'react-router';
import { ImportJobDetail } from '@/features/import-jobs/components/import-job-detail';
import {
  getImportJobQueryOptions,
  useImportJobSuspenseQuery,
} from '@/features/import-jobs/api/get-import-job';

export const clientLoader =
  (queryClient: QueryClient) =>
  async ({ params }: LoaderFunctionArgs) => {
    const importJobId = params.importJobId as string;
    const importJobQuery = getImportJobQueryOptions(importJobId);
    await queryClient.ensureQueryData(importJobQuery);
  };

const ImportJobsViewRoute = () => {
  const params = useParams();
  const importJobId = params.importJobId as string;

  const importJobQuery = useImportJobSuspenseQuery({ importJobId });
  const importJob = importJobQuery.data.importJob;
  console.log('ImportJobsViewRoute importJob:', importJob);

  return <ImportJobDetail importJob={importJob} />;
};

export default ImportJobsViewRoute;
