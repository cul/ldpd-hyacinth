import React from 'react';
import { QueryClient } from '@tanstack/react-query';
import { getUserQueryOptions } from '@/features/users/api/get-user';
import { UserEdit } from '@/features/users/components/user-edit';
import { useParams, LoaderFunctionArgs } from 'react-router';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';

export const clientLoader = (queryClient: QueryClient) => async ({ params }: LoaderFunctionArgs) => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const userUid = params.userUid as string;

  const userQuery = getUserQueryOptions(userUid);
  return (
    queryClient.getQueryData(userQuery.queryKey) ??
    (await queryClient.fetchQuery(userQuery))
  );
};

const UserRoute = () => {
  const params = useParams();
  const userUid = params.userUid as string;

  return <UserEdit userUid={userUid} />;
};

export default UserRoute;