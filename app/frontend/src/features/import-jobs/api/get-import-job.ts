import { queryOptions, useSuspenseQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { ImportJob } from '@/types/api';

export const getImportJob = async (importJobId: string): Promise<{ importJob: ImportJob }> => {
  const res = await api.get<{ importJob: ImportJob }>(`/import_jobs/${importJobId}`);
  return res;
};

export const getImportJobQueryOptions = (importJobId: string) => {
  return queryOptions({
    queryKey: ['import-jobs', importJobId],
    queryFn: () => getImportJob(importJobId),
  });
};

type UseImportJobOptions = {
  importJobId: string;
  queryConfig?: QueryConfig<typeof getImportJobQueryOptions>;
};

export const useImportJobSuspenseQuery = ({ importJobId, queryConfig }: UseImportJobOptions) => {
  return useSuspenseQuery({
    ...getImportJobQueryOptions(importJobId!),
    ...queryConfig,
  });
};
