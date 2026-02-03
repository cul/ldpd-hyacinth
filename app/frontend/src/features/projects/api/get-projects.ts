import { queryOptions, useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';

export type Project = {
  id: number;
  stringKey: string;
  displayLabel: string;
  pid: string;
};

type ProjectsResponse = {
  projects: Project[];
};

export const getProjects = (): Promise<ProjectsResponse> => {
  return api.get('/projects');
};

export const getProjectsQueryOptions = () => {
  return queryOptions({
    queryKey: ['projects'],
    queryFn: () => getProjects(),
  });
};

type UseProjectsOptions = {
  queryConfig?: QueryConfig<typeof getProjectsQueryOptions>;
};

export const useProjects = ({ queryConfig }: UseProjectsOptions = {}) => {
  return useQuery({
    ...getProjectsQueryOptions(),
    ...queryConfig,
  });
};