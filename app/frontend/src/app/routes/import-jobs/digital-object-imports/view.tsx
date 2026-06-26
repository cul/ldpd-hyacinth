import { QueryClient } from '@tanstack/react-query';
// import { ImportJobDetail } from '@/features/import-jobs/components/import-job-detail';
import {
  getDigitalObjectImportQueryOptions,
  useDigitalObjectImportSuspenseQuery,
} from '@/features/digital-object-imports/api/get-digital-object-import';
import { useParams } from 'react-router';

export const clientLoader =
  (queryClient: QueryClient) =>
  async ({ params, request }: any) => {
    const importJobId = params.importJobId as string;
    const digitalObjectImportId = params.digitalObjectImportId as string;
    await queryClient.ensureQueryData(
      getDigitalObjectImportQueryOptions({ importJobId, digitalObjectImportId }),
    );
  };

const DigitalObjectImportsViewRoute = () => {
  const params = useParams();
  const importJobId = params.importJobId as string;
  const digitalObjectImportId = params.digitalObjectImportId as string;

  const data = useDigitalObjectImportSuspenseQuery({ importJobId, digitalObjectImportId });
  console.log('data', data);
  return <div>Hii</div>;
};

export default DigitalObjectImportsViewRoute;
