import React from 'react';
import { QueryClient } from '@tanstack/react-query';
import { useParams } from 'react-router';

// APIs
import { ROLES } from '@/lib/authorization';
import { requireAuthorization } from '@/lib/loader-authorization';
import { getUserProjectsQueryOptions } from '@/features/users/api/get-user-projects';
import { getProjectsQueryOptions } from '@/features/projects/api/get-projects';
import { UserProjectPermissionsForm } from '@/features/users/components/user-project-permissions-form';
import { getUsersQueryOptions } from '@/features/users/api/get-users';

export const clientLoader = (queryClient: QueryClient) => async ({ params }: { params: { userUid: string } }) => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const userUid = params.userUid as string;
  
  // Preload both user project permissions and all projects (for the dropdown of unassigned projects)
  const [userPermissions, projects, users] = await Promise.all([
    queryClient.ensureQueryData(getUserProjectsQueryOptions(userUid)),
    queryClient.ensureQueryData(getProjectsQueryOptions()),
    queryClient.ensureQueryData(getUsersQueryOptions()),
  ]);

  return { userPermissions, projects, users };
};

const UserProjectsRoute = () => {
  const params = useParams();
  const userUid = params.userUid as string;

  return (
    <div>
      {/* TODO: If user is an admin, render a message saying "Admins have full permissions and do not need project-specific permissions." */}
      <UserProjectPermissionsForm userUid={userUid} />
    </div>
  );
};

export default UserProjectsRoute;