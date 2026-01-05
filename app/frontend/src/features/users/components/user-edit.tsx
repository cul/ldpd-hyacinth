import { useUser } from '../api/get-user';
import { useCreateUser } from '../api/create-user';
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

  const createUserMutation = useCreateUser({
    mutationConfig: {
      onSuccess: (data) => {
        console.log('User created successfully:', data);
        alert('User created successfully.');

      },
      onError: (error) => {
        console.error('Error creating user:', error);
      },
    },
  });

  // Move to a proper form later
  const testCreateUser = () => {
    console.log('Test create user button clicked');

    const newUserData = {
      uid: 'newuser123',
      email: 'newuseremail@email.com',
      first_name: 'New',
      last_name: 'User',
      is_admin: false,
      is_active: true,
      can_manage_all_controlled_vocabularies: false,
      account_type: 'standard',
    };

    createUserMutation.mutate({ data: newUserData });
  }

  return (
    <div>
      <UserForm userUid={userUid} />

      <button onClick={testCreateUser}>Test Create User</button>
    </div>
  );
};
