import React from 'react';
import { QueryClient } from '@tanstack/react-query';
import { getUsersQueryOptions } from '@/features/users/api/get-users';
import UsersList from '@/features/users/components/users-list';

export const clientLoader = (queryClient: QueryClient) => async () => {
  const query = getUsersQueryOptions();
  console.log('Trying to get users data from queryClient cache', queryClient.getQueryData(query.queryKey));

  return (
    queryClient.getQueryData(query.queryKey) ??
    (await queryClient.fetchQuery(query))
  );
};

// Eventually, wrap this in a layout that checks for user permissions to view users
const UsersRoute = () => {
  return <UsersList />;
};

export default UsersRoute;