import React, { useMemo } from 'react';
import { QueryClient, useQueryClient } from '@tanstack/react-query';
import { createBrowserRouter, Outlet } from 'react-router';
import { RouterProvider } from 'react-router/dom';
import MainLayout from '@/components/layouts/main-layout';
import { CreateUser } from '@/features/users/components/create-user';

function Root() {
  return (
    <div>
      <p>This is the root of the React app. Currently, nothing is rendered here.</p>
    </div>
  );
}

// Convert a module with clientLoader/clientAction into a route object.
// This allows loaders/actions to access the QueryClient for prefetching data
const convert = (queryClient: QueryClient) => (m: any) => {
  const { clientLoader, clientAction, default: Component, ...rest } = m;
  return {
    ...rest,
    loader: clientLoader?.(queryClient),
    action: clientAction?.(queryClient),
    Component,
  };
};

// TODO: Implement <ProtectedRoute />
export const createAppRouter = (queryClient: QueryClient) =>
  createBrowserRouter([
    {
      Component: MainLayout,
      children: [
        {
          index: true,
          Component: Root,
        },
        {
          path: 'users', // We might want to move user routes under their own layout (to replicate navbar with << Back to Users and other links) or use component composition
          ErrorBoundary: () => <div>Users route error boundary</div>,
          children: [
            {
              index: true,
              lazy: () => import('./routes/app/users').then(convert(queryClient)),
            },
            {
              path: ':userUid/edit',
              lazy: () => import('./routes/app/user').then(convert(queryClient)) // TODO: Move under users/ directory
            },
            { path: ':userUid/edit/project-permissions', Component: () => <div>Edit Project Permissions For User</div> },
            { path: 'new', Component: () => <CreateUser /> }, // For now render CreateUser directly
          ]
        },
        {
          path: 'settings',
          children: [
            {
              index: true,
              lazy: () => import('./routes/app/settings').then(convert(queryClient))
            },
            { path: 'project-permissions', Component: () => <div>Edit Current User Project Permissions</div> },
          ]
        }
      ],
    },
    {
      path: '*',
      lazy: () => import('./routes/not-found').then(convert(queryClient)),
    },
  ], {
    basename: '/ui/v2',
  });

export const AppRouter = () => {
  const queryClient = useQueryClient();

  const router = useMemo(() => createAppRouter(queryClient), [queryClient]);

  return <RouterProvider router={router} />;
};