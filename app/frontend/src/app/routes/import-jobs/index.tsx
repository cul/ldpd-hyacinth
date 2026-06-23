import { Suspense } from 'react';
import { QueryClient } from '@tanstack/react-query';
import { getImportJobsQueryOptions } from '@/features/import-jobs/api/get-import-jobs';
import { QueueActivityDisplay } from '@/features/import-jobs/components/queue-activity-display';
import ImportJobsList from '@/features/import-jobs/components/import-jobs-list';

export const clientLoader = (queryClient: QueryClient) => async () => {
  const query = getImportJobsQueryOptions();
  await queryClient.ensureQueryData(query);
};

const ImportJobsIndexRoute = () => {
  return (
    <>
      <Suspense fallback={<p className="text-muted">Loading activity...</p>}>
        <QueueActivityDisplay />
      </Suspense>

      <ImportJobsList />
    </>
  );
};

export default ImportJobsIndexRoute;
