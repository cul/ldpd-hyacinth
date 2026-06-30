import { QueryClient } from '@tanstack/react-query';
import { useParams, LoaderFunctionArgs } from 'react-router';
import {
  getDigitalObjectImportQueryOptions,
  useDigitalObjectImportSuspenseQuery,
} from '@/features/digital-object-imports/api/get-digital-object-import';
import { DigitalObjectDetail } from '@/features/digital-object-imports/components/digital-object-detail';

export const clientLoader =
  (queryClient: QueryClient) =>
  async ({ params }: LoaderFunctionArgs) => {
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

  const { data } = useDigitalObjectImportSuspenseQuery({ importJobId, digitalObjectImportId });

  return <DigitalObjectDetail digitalObjectImport={data.digitalObjectImport} />;
};

export default DigitalObjectImportsViewRoute;
