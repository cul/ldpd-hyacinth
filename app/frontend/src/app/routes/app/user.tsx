import React from 'react';
import { QueryClient } from '@tanstack/react-query';
import { getUserQueryOptions } from '@/features/users/api/get-user';
import { UserEdit } from '@/features/users/components/user-edit';
import { useParams, LoaderFunctionArgs } from 'react-router';

export const clientLoader =
  (queryClient: QueryClient) =>
  async ({ params }: LoaderFunctionArgs) => {
    const userUid = params.userUid as string;

    const userQuery = getUserQueryOptions(userUid);
      return (
    queryClient.getQueryData(userQuery.queryKey) ??
    (await queryClient.fetchQuery(userQuery))
  );
  };

// Eventually, wrap this in a layout that checks for user permissions to view users
const UserRoute = () => {
  const params = useParams();
  console.log('UserRoute params:', params);
  const userUid = params.userUid as string;

  return <UserEdit userUid={userUid} />;
};

export default UserRoute;