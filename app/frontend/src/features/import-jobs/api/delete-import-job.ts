import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { getImportJobQueryOptions } from './get-import-job';

export const deleteImportJob = ({
  importJobId,
}: {
  importJobId: string;
}): Promise<Record<string, never>> => {
  return api.delete(`/import_jobs/${importJobId}`);
};

type UseDeleteImportJobOptions = {
  mutationConfig?: MutationConfig<typeof deleteImportJob>;
};

export const useDeleteImportJob = ({ mutationConfig }: UseDeleteImportJobOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  return useMutation({
    onSuccess: (data, variables, ...args) => {
      queryClient.removeQueries({
        queryKey: getImportJobQueryOptions(variables.importJobId).queryKey,
      });
      // Refetch the list so the deleted row disappears and counts/pagination is updated
      queryClient.invalidateQueries({ queryKey: ['import-jobs'] });
      onSuccess?.(data, variables, ...args);
    },
    ...restConfig,
    mutationFn: deleteImportJob,
  });
};
