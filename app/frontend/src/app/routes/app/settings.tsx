import { QueryClient } from '@tanstack/react-query';
import { getUserQueryOptions } from '@/features/users/api/get-user';
import { useUser } from '@/lib/auth';
import { UserForm } from '@/features/users/components/user-form';

// Prefetch the current user's full data
export const clientLoader = (queryClient: QueryClient) => async () => {
  // Get the current user UID from the auth query cache
  const authUser = queryClient.getQueryData(['authenticated-user']) as any;
  
  if (!authUser?.uid) {
    return null;
  }

  const userQuery = getUserQueryOptions(authUser.uid);
  return (
    queryClient.getQueryData(userQuery.queryKey) ??
    (await queryClient.fetchQuery(userQuery))
  );
};

const SettingsRoute = () => {
  const user = useUser();

  if (!user.data) return null;

  return <UserForm userUid={user.data.uid} />;
};

export default SettingsRoute;