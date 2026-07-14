import { Suspense } from 'react';
import { QueryClient } from '@tanstack/react-query';
import { useParams, LoaderFunctionArgs } from 'react-router';
import { getDigitalObjectImportsQueryOptions } from '@/features/digital-object-imports/api/get-digital-object-imports';
import { DigitalObjectImportsList } from '@/features/digital-object-imports/components/digital-object-imports-list';

export const clientLoader =
  (queryClient: QueryClient) =>
  async ({ params, request }: LoaderFunctionArgs) => {
    const importJobId = params.importJobId as string;
    const url = new URL(request.url);
    const page = Number(url.searchParams.get('page')) || 1;
    const status = url.searchParams.get('status') ?? undefined;

    await queryClient.ensureQueryData(
      getDigitalObjectImportsQueryOptions({ importJobId, page, status }),
    );
  };

const DigitalObjectImportsRoute = () => {
  const params = useParams();
  const importJobId = params.importJobId as string;

  return (
    <Suspense fallback={<p className="text-muted">Loading imports...</p>}>
      <DigitalObjectImportsList importJobId={importJobId} />
    </Suspense>
  );
};

export default DigitalObjectImportsRoute;
