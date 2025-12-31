import React from 'react';
import { Link } from 'react-router';
import type { ColumnDef } from '@tanstack/react-table';
import { Spinner } from 'react-bootstrap';

import TableBuilder from '@/components/ui/TableBuilder/table-builder';
import { User } from '@/types/api';
import { useUsers } from '@/features/users/api/get-users';
import { columnDefs } from './columns'

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
      {/* TODO: Move "Create New User" link to its own layout if we want to replicate navbar with << Back to Users and other links */}
      <Link to="/users/new">Create New User</Link> 
      <TableBuilder data={users} columns={columnDefs as ColumnDef<User>[]} />
    </div>
  );
}

export default UsersList;
