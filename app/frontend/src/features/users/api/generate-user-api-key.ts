import { useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';

type GenerateApiKeyResponse = {
  apiKey: string;
};

export const generateUserApiKey = ({userUid}: {userUid: string;}): Promise<GenerateApiKeyResponse> => {
  return api.post(`/users/${userUid}/generate_new_api_key`);
};

type UseGenerateUserApiKeyOptions = {
  mutationConfig?: MutationConfig<typeof generateUserApiKey>;
};

export const useGenerateUserApiKey = ({
  mutationConfig,
}: UseGenerateUserApiKeyOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  // ? Do we need to invalidate a specific query?
  return useMutation({
    onSuccess: (...args) => {
      queryClient.invalidateQueries({
        queryKey: ['user', args[1].userUid],
      });
      onSuccess?.(...args);
    },
    ...restConfig,
    mutationFn: generateUserApiKey,
  });
}