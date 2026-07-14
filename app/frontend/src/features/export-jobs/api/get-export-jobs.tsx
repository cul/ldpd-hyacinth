import { queryOptions, useSuspenseQuery, keepPreviousData } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { ExportJob, Pagination } from '@/types/api';

export interface ExportJobsResponse {
  exportJobs: ExportJob[];
  pagination: Pagination;
}

export const getExportJobs = async (page: number): Promise<ExportJobsResponse> => {
  const res = await api.get<ExportJobsResponse>(`/csv_exports?page=${page}`);
  return res;
};

export const getExportJobsQueryOptions = (page: number) => {
  return queryOptions({
    queryKey: ['export-jobs', { page }],
    queryFn: () => getExportJobs(page),
  });
};

type UseExportJobsOptions = {
  page: number;
  queryConfig?: QueryConfig<typeof getExportJobsQueryOptions>;
};

export const useExportJobsSuspenseQuery = ({ page, queryConfig }: UseExportJobsOptions) => {
  return useSuspenseQuery({
    ...getExportJobsQueryOptions(page),
    placeholderData: keepPreviousData, // Eliminates the flash of the table when changing pages
    ...queryConfig,
  });
};
