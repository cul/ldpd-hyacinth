import React from 'react';
import { QueryClient } from '@tanstack/react-query';
import { CreateUser } from '@/features/users/components/create-user';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);
  return null;
};

const UsersNewRoute = () => {
  return <CreateUser />;
};

export default UsersNewRoute;