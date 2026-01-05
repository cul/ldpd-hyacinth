import { useUser } from '../api/get-user';
import { UserForm } from './user-form';

export const UserEdit = ({ userUid }: { userUid: string }) => {
  const userQuery = useUser({
    userUid,
  });

  if (userQuery.isLoading) {
    return (
      <div>
        Loading...
      </div>
    );
  }

  const user = userQuery?.data?.user;

  if (!user) return null;

  return (
    <div>
      <UserForm userUid={userUid} />
    </div>
  );
};
