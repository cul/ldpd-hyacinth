import React, { useState } from 'react';

import { useEffect } from "react";
import { getUsers } from "../api/get-users";

const UsersList = () => {
  const [users, setUsers] = useState<any[]>([]);

  useEffect(() => {
    const fetchUsers = async () => {
      const users = await getUsers();
      setUsers(users);
      console.log(users);
    };

    fetchUsers();
  }, []);

  return (<div>
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
  </div>
  );
}

export default UsersList;
