import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { PublishTarget } from '@/types/api';
import { getPublishTargetsQueryOptions } from './get-publish-targets';

export const createPublishTarget = ({ data }: { data: Partial<PublishTarget> }): Promise<{ publishTarget: PublishTarget }> => {
  return api.post(`/publish_targets`, { publishTarget: data });
};

type UseCreatePublishTargetOptions = {
  mutationConfig?: MutationConfig<typeof createPublishTarget>;
};

export const useCreatePublishTarget = ({
  mutationConfig,
}: UseCreatePublishTargetOptions = {}) => {
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
    mutationFn: createPublishTarget,
  });
};
