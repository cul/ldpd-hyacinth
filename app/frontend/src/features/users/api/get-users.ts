import { queryOptions, useQuery } from '@tanstack/react-query';
import { api } from '../../../lib/api-client';
import { User } from '../../../types/api.ts';
import { QueryConfig } from '../../../lib/react-query';

export const getUsers = async (): Promise<{ users: User[] }> => {
  // Simulate network delay for testing isLoading
  // await new Promise((resolve) => setTimeout(resolve, 2000));
  return api.get('/users');
};

export const getUsersQueryOptions = () => {
  return queryOptions({
    queryKey: ['users'],
    queryFn: getUsers,
  });
};

type UseUsersOptions = {
  queryConfig?: QueryConfig<typeof getUsersQueryOptions>;
};

export const useUsers = ({ queryConfig }: UseUsersOptions = {}) => {
  return useQuery({
    ...getUsersQueryOptions(),
    ...queryConfig,
  });
};
