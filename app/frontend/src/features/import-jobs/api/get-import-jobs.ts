import { queryOptions, useSuspenseQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { ImportJob } from '@/types/api';

export const getImportJobs = async (): Promise<{ importJobs: ImportJob[] }> => {
  const res = await api.get<{ importJobs: ImportJob[] }>('/import_jobs');
  console.log('getImportJobs response:', res);
  return res;
};

export const getImportJobsQueryOptions = () => {
  return queryOptions({
    queryKey: ['import-jobs'],
    queryFn: getImportJobs,
  });
};

type UseImportJobsOptions = {
  queryConfig?: QueryConfig<typeof getImportJobsQueryOptions>;
};

export const useImportJobsSuspenseQuery = ({ queryConfig }: UseImportJobsOptions = {}) => {
  return useSuspenseQuery({
    ...getImportJobsQueryOptions(),
    ...queryConfig,
  });
};
