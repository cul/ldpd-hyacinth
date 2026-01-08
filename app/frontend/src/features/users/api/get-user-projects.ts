import { queryOptions, useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';

// TODO: Add project type
export const getUserProjects = async (userUid: string): Promise<{ projectPermissions: any }> => {
  const res = await api.get<{ projectPermissions: any }>(`/users/${userUid}/project_permissions`);
  // TODO: Handle gracefully if no permissions are found
  return res.projectPermissions.projects;
};

export const getUserProjectsQueryOptions = (userUid: string) => {
  return queryOptions({
    queryKey: ['users', userUid, 'projects'],
    queryFn: () => getUserProjects(userUid),
  });
};

type UseUserProjectsOptions = {
  userUid: string;
  queryConfig?: QueryConfig<typeof getUserProjectsQueryOptions>;
};

export const useUserProjects = ({ userUid, queryConfig }: UseUserProjectsOptions) => {
  return useQuery({
    ...getUserProjectsQueryOptions(userUid),
    ...queryConfig,
  });
};
