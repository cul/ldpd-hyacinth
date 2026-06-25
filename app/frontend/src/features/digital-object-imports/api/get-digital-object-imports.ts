import { queryOptions, useSuspenseQuery, keepPreviousData } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { DigitalObjectImportSummary } from '@/types/api';
// TODO: Move pagination into a shared type file since it's used in multiple places
import { Pagination } from '@/features/import-jobs/api/get-import-jobs';

export interface DigitalObjectImportsResponse {
  digitalObjectImports: DigitalObjectImportSummary[];
  pagination: Pagination;
  statusFilter: string | null;
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
    ...getDigitalObjectImportsQueryOptions(params),
    // placeholderData: keepPreviousData,
  });
};
