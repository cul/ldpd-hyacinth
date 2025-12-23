import React from 'react';
import { useUsers } from "../api/get-users";
import { Spinner } from 'react-bootstrap';
import TableBuilder from '../../../components/ui/TableBuilder/table-builder';

const UsersList = () => {
  const usersQuery = useUsers();

  if (usersQuery.isLoading) {
    return <Spinner />
  }

  const users = usersQuery.data?.users;
  if (!users) return null;

  return (
    <div>
      <h1>Users List</h1>
      {users.length === 0 ? (
        <p>No users found.</p>
      ) : (
        <ul>
          {users.map((user: any) => (
            <li key={user.uid}>
              {user.first_name} {user.last_name} ({user.email})
            </li>
          ))}
        </ul>
      )}
      <TableBuilder data={users} />
    </div>
  );
}

export default UsersList;
