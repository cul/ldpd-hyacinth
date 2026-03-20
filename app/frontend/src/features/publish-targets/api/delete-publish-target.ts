import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { getPublishTargetsQueryOptions } from './get-publish-targets';

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
    onSuccess: (...args) => {
      queryClient.invalidateQueries({
        queryKey: getPublishTargetsQueryOptions().queryKey,
      });
      onSuccess?.(...args);
    },
    ...restConfig,
    mutationFn: deletePublishTarget,
  });
};
