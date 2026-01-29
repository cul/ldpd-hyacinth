import { QueryClient } from '@tanstack/react-query';
import { useParams, LoaderFunctionArgs } from 'react-router';

import UserProjectPermissionsForm from '@/features/users/components/UserProjectPermissionsForm';
import { ROLES } from '@/lib/authorization';
import { requireAuthorization } from '@/lib/loader-authorization';
import { getUserProjectsQueryOptions } from '@/features/users/api/get-user-projects';
import { getProjectsQueryOptions } from '@/features/projects/api/get-projects';
import { getUsersQueryOptions } from '@/features/users/api/get-users';
import { getUserQueryOptions, useUser } from '@/features/users/api/get-user';

export const clientLoader = (queryClient: QueryClient) => async ({ params }: LoaderFunctionArgs) => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const userUid = params.userUid as string;
  const { user } = await queryClient.ensureQueryData(getUserQueryOptions(userUid));

  // If user is an admin, they have access to all projects by default
  // No need to fetch projects or users list for the form
  if (user.isAdmin) {
    return { user };
  }

  const [userPermissions, projects, users] = await Promise.all([
    queryClient.ensureQueryData(getUserProjectsQueryOptions(userUid)),
    queryClient.ensureQueryData(getProjectsQueryOptions()),
    queryClient.ensureQueryData(getUsersQueryOptions()),
  ]);

  return { user, userPermissions, projects, users };
};

export const UsersProjectPermissionsRoute = () => {
  const params = useParams();
  const userUid = params.userUid as string;

  const { data: userData, isLoading } = useUser({ userUid });

  if (isLoading) {
    return <div>Loading...</div>;
  }

  const user = userData?.user;

  if (!user) return null;

  return (
    <div>
      {user.isAdmin ? (
        <div className="alert alert-info">
          <h5>Admin User</h5>
          <p>
            Admins have full permissions for all projects and do not need project-specific permissions.
          </p>
        </div>
      ) : (
        <UserProjectPermissionsForm userUid={userUid} />
      )}
    </div>
  );
};

export default UsersProjectPermissionsRoute;