import React from 'react';
import { QueryClient } from '@tanstack/react-query';
import { getUserProjectsQueryOptions } from '@/features/users/api/get-user-projects';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { UserProjectPermissionsForm } from '@/features/users/components/user-project-permissions-form';
import { useParams } from 'react-router';

export const clientLoader = (queryClient: QueryClient) => async ({ params }: { params: { userUid: string } }) => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const userUid = params.userUid as string;
  const query = getUserProjectsQueryOptions(userUid);

  console.log('Fetching user projects for userUid:', userUid);
  console.log('Using query key:', query.queryKey);

  return (
    queryClient.getQueryData(query.queryKey) ??
    (await queryClient.fetchQuery(query))
  );
};

const UserProjectsRoute = () => {
  const params = useParams();
  const userUid = params.userUid as string;

  return (
    <div>
      <UserProjectPermissionsForm userUid={userUid} />
    </div>
  )
};

export default UserProjectsRoute;