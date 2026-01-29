import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { User } from '@/types/api';
import { getUsersQueryOptions } from './get-users';
import { AUTH_QUERY_KEY } from '@/lib/auth';

export const updateUser = ({
  userUid,
  data,
}: {
  userUid: string;
  data: Partial<User>;
}): Promise<{ user: User }> => {
  return api.patch(`/users/${userUid}`, { user: data });
};

type UseUpdateUserOptions = {
  mutationConfig?: MutationConfig<typeof updateUser>;
};

export const useUpdateUser = ({
  mutationConfig,
}: UseUpdateUserOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  return useMutation({
    onSuccess: (data, variables, ...args) => {
      queryClient.invalidateQueries({
        queryKey: getUsersQueryOptions().queryKey,
      });

      // If updating current user, refresh auth state
      const currentUser = queryClient.getQueryData<User>(AUTH_QUERY_KEY);
      if (currentUser?.uid === variables.userUid) {
        queryClient.invalidateQueries({ queryKey: AUTH_QUERY_KEY });
      }

      onSuccess?.(data, variables, ...args);
    },
    ...restConfig,
    mutationFn: updateUser,
  });
};
