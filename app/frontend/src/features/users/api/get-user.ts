import { queryOptions, useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { User } from '@/types/api';

export const getUser = async (userUid: string): Promise<{ user: User }> => {
  const res = await api.get<{ user: User }>(`/users/${userUid}`);
  return res;
};

export const getUserQueryOptions = (userUid: string) => {
  return queryOptions({
    queryKey: ['users', userUid],
    queryFn: () => getUser(userUid),
  });
};

type UseUserOptions = {
  userUid: string;
  queryConfig?: QueryConfig<typeof getUserQueryOptions>;
};

export const useUser = ({ userUid, queryConfig }: UseUserOptions) => {
  return useQuery({
    ...getUserQueryOptions(userUid!),
    ...queryConfig,
  });
};
