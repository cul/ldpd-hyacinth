import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';

export const deleteExportJob = ({
  exportJobId,
}: {
  exportJobId: string;
}): Promise<Record<string, never>> => {
  return api.delete(`/csv_exports/${exportJobId}`);
};

type UseDeleteExportJobOptions = {
  mutationConfig?: MutationConfig<typeof deleteExportJob>;
};

export const useDeleteExportJob = ({ mutationConfig }: UseDeleteExportJobOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  return useMutation({
    onSuccess: (data, variables, ...args) => {
      queryClient.removeQueries({
        queryKey: ['export-jobs', { exportJobId: variables.exportJobId }],
      });
      // Refetch the list so the deleted row disappears and counts/pagination is updated
      queryClient.invalidateQueries({ queryKey: ['export-jobs'] });
      onSuccess?.(data, variables, ...args);
    },
    ...restConfig,
    mutationFn: deleteExportJob,
  });
};
