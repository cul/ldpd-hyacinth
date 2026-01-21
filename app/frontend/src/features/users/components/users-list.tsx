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
    return <Spinner />;
  }

  const users = usersQuery.data?.users;
  if (!users) return null;

  return (
    <TableBuilder data={users} columns={columnDefs as ColumnDef<User>[]} />
  );
}

export default UsersList;
