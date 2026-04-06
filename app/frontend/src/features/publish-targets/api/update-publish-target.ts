import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { PublishTarget, PublishTargetPayload } from '@/types/api';
import { getPublishTargetsQueryOptions } from './get-publish-targets';

export const updatePublishTarget = ({
  publishTargetStringKey,
  data,
}: {
  publishTargetStringKey: string;
  data: Partial<PublishTargetPayload>;
}): Promise<{ publishTarget: PublishTarget }> => {
  return api.patch(`/publish_targets/${publishTargetStringKey}`, { publishTarget: data });
};

type UseUpdatePublishTargetOptions = {
  mutationConfig?: MutationConfig<typeof updatePublishTarget>;
};

export const useUpdatePublishTarget = ({
  mutationConfig,
}: UseUpdatePublishTargetOptions = {}) => {
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
    mutationFn: updatePublishTarget,
  });
};
