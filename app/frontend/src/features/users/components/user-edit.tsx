import { useUser } from '../api/get-user';
import { useCreateUser } from '../api/create-user';


export const UserView = ({ userUid }: { userUid: string }) => {
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
      account_type: 0,
    };

    createUserMutation.mutate({ data: newUserData });
  }

  return (
    <div>
      <span className="ml-2 text-sm font-bold">
        {/* TODO: Create a user form */}
        <div>UID: {user.uid}</div>
        <div>Email: {user.email}</div>
        <div>First Name: {user.first_name}</div>
        <div>Last Name: {user.last_name}</div>
        <div>Is admin: {user.is_admin ? 'Yes' : 'No'}</div>
        <div>Can manage controlled vocabularies: {user.can_manage_all_controlled_vocabularies ? 'Yes' : 'No'}</div>
        <div>Account type: {user.account_type}</div>
        <div>Is active? {user.is_active ? 'Yes' : 'No'}</div>

        <button onClick={testCreateUser}>Test Create User</button>
      </span>
    </div>
  );
};
