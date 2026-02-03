import { useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { ProjectPermission } from '@/types/api';
import { getUserProjectsQueryOptions } from './get-user-projects';

const updateUserProjectPermissions = ({
  userUid,
  projectPermissions,
}: {
  userUid: string;
  projectPermissions: ProjectPermission[];
}): Promise<{ projectPermissions: ProjectPermission[] }> => {
  return api.put(`/users/${userUid}/project_permissions`, { projectPermissions });
};

type UseUpdateUserProjectPermissionsOptions = {
  mutationConfig?: MutationConfig<typeof updateUserProjectPermissions>;
};

export const useUpdateUserProjectPermissions = ({
  mutationConfig,
}: UseUpdateUserProjectPermissionsOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  return useMutation({
    mutationFn: updateUserProjectPermissions,
    onSuccess: (...args) => {
      queryClient.invalidateQueries({
        queryKey: getUserProjectsQueryOptions(args[1].userUid).queryKey,
      });

      // Call the provided onSuccess callback if any
      onSuccess?.(...args);
    },
    ...restConfig,
  });
};
