import { useMutation, useQueryClient } from '@tanstack/react-query';
// import { z } from 'zod'; // use Zod?

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { User } from '@/types/api';

import { getUsersQueryOptions } from './get-users';

export const createUser = ({
  data,
}: {
  data: Partial<User>;
}): Promise<{ user: User }> => {
  return api.post(`/users`, { user: data });
};

type UseCreateUserOptions = {
  mutationConfig?: MutationConfig<typeof createUser>;
};

export const useCreateUser = ({
  mutationConfig,
}: UseCreateUserOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  return useMutation({
    onSuccess: (...args) => {
      queryClient.invalidateQueries({
        queryKey: getUsersQueryOptions().queryKey,
      });
      onSuccess?.(...args);
    },
    ...restConfig,
    mutationFn: createUser,
  });
};
