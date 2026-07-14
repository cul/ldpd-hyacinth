import { queryOptions, useSuspenseQuery, keepPreviousData } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { DigitalObjectImportSummary, Pagination } from '@/types/api';

export interface DigitalObjectImportsResponse {
  digitalObjectImports: DigitalObjectImportSummary[];
  pagination: Pagination;
  statusFilter: string | null;
  importJobName: string;
}

interface DigitalObjectImportsQueryParams {
  importJobId: string;
  page?: number;
  status?: string;
}

export const getDigitalObjectImports = ({
  importJobId,
  page = 1,
  status,
}: DigitalObjectImportsQueryParams): Promise<DigitalObjectImportsResponse> => {
  const query = new URLSearchParams({ page: String(page) });
  if (status) query.set('status', status);

  return api.get<DigitalObjectImportsResponse>(
    `/import_jobs/${importJobId}/digital_object_imports?${query.toString()}`,
  );
};

export const getDigitalObjectImportsQueryOptions = ({
  importJobId,
  page = 1,
  status,
}: DigitalObjectImportsQueryParams) => {
  return queryOptions({
    queryKey: ['digital-object-imports', importJobId, { page, status: status ?? null }],
    queryFn: () => getDigitalObjectImports({ importJobId, page, status }),
  });
};

export const useDigitalObjectImportsSuspenseQuery = (params: DigitalObjectImportsQueryParams) => {
  return useSuspenseQuery({
    placeholderData: keepPreviousData,
    ...getDigitalObjectImportsQueryOptions(params),
  });
};
