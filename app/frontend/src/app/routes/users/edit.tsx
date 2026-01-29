import { QueryClient } from '@tanstack/react-query';
import { getUserQueryOptions } from '@/features/users/api/get-user';
import { UserEdit } from '@/features/users/components/user-edit';
import { useParams, LoaderFunctionArgs, redirect } from 'react-router';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';

export const clientLoader = (queryClient: QueryClient) => async ({ params }: LoaderFunctionArgs) => {
  const currentUser = await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const userUid = params.userUid as string;

  // Redirect to settings if user is trying to edit themselves
  if (currentUser.uid === userUid) {
    throw redirect('/settings');
  }

  const userQuery = getUserQueryOptions(userUid);

  return await queryClient.ensureQueryData(userQuery);
};

const UsersEditRoute = () => {
  const params = useParams();
  const userUid = params.userUid as string;

  return <UserEdit userUid={userUid} />;
};

export default UsersEditRoute;