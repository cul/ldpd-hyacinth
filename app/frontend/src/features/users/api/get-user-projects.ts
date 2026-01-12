import { queryOptions, useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { ProjectPermission } from '@/types/api';

export const getUserProjects = async (userUid: string): Promise<ProjectPermission[]> => {
  const res = await api.get<{ projectPermissions: ProjectPermission[] }>(`/users/${userUid}/project_permissions`);
  return res.projectPermissions || [];
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
