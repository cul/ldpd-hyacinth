import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { getPublishTargetsQueryOptions } from './get-publish-targets';
import { getPublishTargetQueryOptions } from './get-publish-target';

export const deletePublishTarget = ({ publishTargetStringKey }: { publishTargetStringKey: string }): Promise<Record<string, never>> => {
  return api.delete(`/publish_targets/${publishTargetStringKey}`);
};

type UseDeletePublishTargetOptions = {
  mutationConfig?: MutationConfig<typeof deletePublishTarget>;
};

export const useDeletePublishTarget = ({
  mutationConfig,
}: UseDeletePublishTargetOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  return useMutation({
    onSuccess: (variables, ...args) => {
      // Remove the deleted target's query from the cache entirely to prevent 
      // a stale refetch of a target that no longer exists.
      queryClient.removeQueries({
        queryKey: getPublishTargetQueryOptions(variables.publishTargetStringKey).queryKey,
      });

      queryClient.invalidateQueries({
        queryKey: getPublishTargetsQueryOptions().queryKey,
        exact: true, // Prevents invalidating other ['publish-targets', ...] queries
      });
      onSuccess?.(variables, ...args);
    },
    ...restConfig,
    mutationFn: deletePublishTarget,
  });
};
