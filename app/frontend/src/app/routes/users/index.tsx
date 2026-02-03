import React from 'react';
import { QueryClient } from '@tanstack/react-query';
import { getUsersQueryOptions } from '@/features/users/api/get-users';
import UsersList from '@/features/users/components/users-list';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const query = getUsersQueryOptions();

  return (
    queryClient.getQueryData(query.queryKey) ??
    (await queryClient.fetchQuery(query))
  );
};

const UsersIndexRoute = () => {
  return <UsersList />
};

export default UsersIndexRoute;