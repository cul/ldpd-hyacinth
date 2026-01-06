import React, { useMemo } from 'react';
import { QueryClient, useQueryClient } from '@tanstack/react-query';
import { createBrowserRouter } from 'react-router';
import { RouterProvider } from 'react-router/dom';

// Layouts and Components
import MainLayout from '@/components/layouts/main-layout';
import { CreateUser } from '@/features/users/components/create-user';
import { AuthorizationErrorBoundary } from '@/components/errors/authorization-error';

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
          path: 'users',
          ErrorBoundary: AuthorizationErrorBoundary, // Catch authorization errors from loaders
          children: [
            {
              index: true,
              lazy: () => import('./routes/users/users').then(convert(queryClient)),
            },
            {
              path: ':userUid/edit',
              lazy: () => import('./routes/users/user').then(convert(queryClient)),
            },
            {
              path: ':userUid/edit/project-permissions',
              Component: () => <div>Edit Project Permissions For User</div>,
            },
            {
              path: 'new',
              Component: () => <CreateUser />,
            },
          ]
        },
        {
          path: 'settings',
          children: [
            {
              index: true,
              lazy: () => import('./routes/settings').then(convert(queryClient))
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