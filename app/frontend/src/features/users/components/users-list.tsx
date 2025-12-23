import React from 'react';
import type { ColumnDef } from '@tanstack/react-table';
import { Spinner } from 'react-bootstrap';

import TableBuilder from '../../../components/ui/TableBuilder/table-builder';
import type { User } from '../../../types/api';
import { useUsers } from "../api/get-users";
import { columnDefs } from './columns.tsx'

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
      <TableBuilder data={users} columns={columnDefs as ColumnDef<User>[]} />
    </div>
  );
}

export default UsersList;
