import { queryOptions, useSuspenseQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { DigitalObjectImport } from '@/types/api';

export const getDigitalObjectImport = async ({
  importJobId,
  digitalObjectImportId,
}: {
  importJobId: string;
  digitalObjectImportId: string;
}): Promise<{ digitalObjectImport: DigitalObjectImport }> => {
  const res = await api.get<{ digitalObjectImport: DigitalObjectImport }>(
    `/import_jobs/${importJobId}/digital_object_imports/${digitalObjectImportId}`,
  );
  return res;
};

export const getDigitalObjectImportQueryOptions = ({
  importJobId,
  digitalObjectImportId,
}: {
  importJobId: string;
  digitalObjectImportId: string;
}) => {
  return queryOptions({
    queryKey: ['digital-object-imports', importJobId, digitalObjectImportId],
    queryFn: () => getDigitalObjectImport({ importJobId, digitalObjectImportId }),
  });
};

type UseImportJobOptions = {
  importJobId: string;
  digitalObjectImportId: string;
  queryConfig?: QueryConfig<typeof getDigitalObjectImportQueryOptions>;
};

export const useDigitalObjectImportSuspenseQuery = ({
  importJobId,
  digitalObjectImportId,
  queryConfig,
}: UseImportJobOptions) => {
  return useSuspenseQuery({
    ...getDigitalObjectImportQueryOptions({
      importJobId: importJobId!,
      digitalObjectImportId: digitalObjectImportId!,
    }),
    ...queryConfig,
  });
};
