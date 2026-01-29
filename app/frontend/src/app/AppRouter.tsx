import { useMemo } from 'react';
import { QueryClient, useQueryClient } from '@tanstack/react-query';
import { createBrowserRouter, LoaderFunction, ActionFunction } from 'react-router';
import { RouterProvider } from 'react-router/dom';

// Layouts and Components
import MainLayout from '@/components/layouts/MainLayout';
import UsersLayout from '@/components/layouts/UsersLayout';
import UserLayout from '@/components/layouts/UserLayout';
import AuthorizationErrorBoundary from '@/components/errors/AuthorizationErrorBoundary';

function Root() {
  return (
    <div>
      <p>This is the root of the React app. Currently, nothing is rendered here.</p>
    </div>
  );
}

interface RouteModule {
  default: React.ComponentType;
  clientLoader?: (queryClient: QueryClient) => LoaderFunction;
  clientAction?: (queryClient: QueryClient) => ActionFunction;
  [key: string]: unknown;
}

// Convert a module with clientLoader/clientAction into a route object.
// This allows loaders/actions to access the QueryClient for prefetching data
const convert = (queryClient: QueryClient) => (m: RouteModule) => {
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
          Component: UsersLayout, // Wraps all users routes with shared navigation
          ErrorBoundary: AuthorizationErrorBoundary, // Catch authorization errors from loaders
          children: [
            {
              index: true,
              lazy: () => import('./routes/users/UsersIndexRoute').then(convert(queryClient)),
            },
            {
              path: ':userUid',
              Component: UserLayout,
              children: [
                {
                  path: 'edit', // maybe this should be the default (index) route under :userUid
                  lazy: () => import('./routes/users/UsersEditRoute').then(convert(queryClient)),
                },
                {
                  path: 'project-permissions/edit',
                  lazy: () => import('./routes/users/UsersProjectPermissionsRoute').then(convert(queryClient)),
                },
              ]
            },
            {
              path: 'new',
              lazy: () => import('./routes/users/UsersNewRoute').then(convert(queryClient)),
            },
          ]
        },
        {
          path: 'settings',
          children: [
            {
              index: true,
              lazy: () => import('./routes/settings/SettingsIndexRoute').then(convert(queryClient))
            },
            {
              path: 'project-permissions',
              lazy: () => import('./routes/settings/SettingsProjectPermissionsRoute').then(convert(queryClient))
            },
          ]
        }
      ],
    },
    {
      path: '*',
      lazy: () => import('./routes/NotFound').then(convert(queryClient)),
    },
  ], {
    basename: '/ui/v2',
  });

export default function AppRouter() {
  const queryClient = useQueryClient();

  const router = useMemo(() => createAppRouter(queryClient), [queryClient]);

  return <RouterProvider router={router} />;
};