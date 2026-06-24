import { queryOptions, useSuspenseQuery, keepPreviousData } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { ImportJob } from '@/types/api';

export interface Pagination {
  currentPage: number;
  perPage: number;
  totalPages: number;
  totalCount: number;
}

export interface ImportJobsResponse {
  importJobs: ImportJob[];
  pagination: Pagination;
}

export const getImportJobs = async (page: number): Promise<ImportJobsResponse> => {
  const res = await api.get<ImportJobsResponse>(`/import_jobs?page=${page}`);
  console.log('getImportJobs response:', res);
  return res;
};

export const getImportJobsQueryOptions = (page: number) => {
  return queryOptions({
    queryKey: ['import-jobs', { page }],
    queryFn: () => getImportJobs(page),
  });
};

type UseImportJobsOptions = {
  page: number;
  queryConfig?: QueryConfig<typeof getImportJobsQueryOptions>;
};

export const useImportJobsSuspenseQuery = ({ page, queryConfig }: UseImportJobsOptions) => {
  return useSuspenseQuery({
    ...getImportJobsQueryOptions(page),
    placeholderData: keepPreviousData, // Eliminates the flash of the table when changing pages
    ...queryConfig,
  });
};
