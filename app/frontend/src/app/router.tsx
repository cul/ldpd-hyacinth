// import { QueryClient, useQueryClient } from '@tanstack/react-query';
import React from 'react';
import { useMemo } from 'react';
import { createBrowserRouter, Outlet } from 'react-router';
import { RouterProvider } from 'react-router/dom';

import NotFoundRoute from './routes/not-found.tsx';
import MainLayout from '../components/layouts/main-layout.tsx';
import UsersList from '../features/users/components/users-list.tsx';

function Root() {
  return (
    <div>
      <p>This is the root of the React app. Currently, nothing is rendered here.</p>
    </div>
  );
}

// TODO: Implement <ProtectedRoute />
export const createAppRouter = () =>
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
            { index: true, Component: UsersList },
            // Uncomment to test error boundary
            // {
            //   index: true, Component: () => {
            //     throw new Error('Test error!');
            //     return <div>Users Index</div>;
            //   }
            // },
            { path: ':uid/edit', Component: () => <div>User Edit</div> },
            { path: ':uid/edit/project-permissions', Component: () => <div>Edit Project Permissions For User</div> },
            { path: 'new', Component: () => <div>New User</div> },
          ]
        },
        {
          path: 'settings',
          children: [
            { index: true, Component: () => <div>Current User Edit</div> },
            { path: 'project-permissions', Component: () => <div>Edit Current User Project Permissions</div> },
          ]
        }
      ],
    },
    {
      path: '*',
      element: <NotFoundRoute />,
    },
  ], {
    basename: '/ui/v2',
  });

export const AppRouter = () => {
  const router = useMemo(() => createAppRouter(), []);

  return <RouterProvider router={router} />;
};