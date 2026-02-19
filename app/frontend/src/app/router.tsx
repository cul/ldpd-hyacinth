import { useMemo } from 'react';
import { QueryClient, useQueryClient } from '@tanstack/react-query';
import { createBrowserRouter, LoaderFunction, ActionFunction, LoaderFunctionArgs } from 'react-router';
import { RouterProvider } from 'react-router/dom';

// Layouts and Components
import MainLayout from '@/components/layouts/main-layout';
import UsersLayout from '@/components/layouts/users-layout';
import UserLayout from '@/components/layouts/user-layout';
import { AuthorizationErrorBoundary } from '@/components/errors/authorization-error';
import { sleep } from '../utils/sleep-utils';

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

const wrapLoaderWithStatusEvents = (loaderFunction: LoaderFunction | undefined) => {
  if (!loaderFunction) { return undefined; }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return async (args: LoaderFunctionArgs<any>, handlerCtx?: unknown) => {
    window.dispatchEvent(new CustomEvent('clientLoaderStart'));
    await sleep(1000); // TODO: <------------------------------------------------ Delete this line once testing is complete!
    const loaderFunctionResult = await loaderFunction(args, handlerCtx);
    window.dispatchEvent(new CustomEvent('clientLoaderComplete'));
    return loaderFunctionResult;
  };
}

// Convert a module with clientLoader/clientAction into a route object.
// This allows loaders/actions to access the QueryClient for prefetching data
const convert = (queryClient: QueryClient) => (m: RouteModule) => {
  const { clientLoader, clientAction, default: Component, ...rest } = m;
  return {
    ...rest,
    loader: wrapLoaderWithStatusEvents(clientLoader?.(queryClient)),
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
              lazy: () => import('./routes/users').then(convert(queryClient)),
            },
            {
              path: ':userUid',
              Component: UserLayout,
              children: [
                {
                  path: 'edit', // maybe this should be the default (index) route under :userUid
                  lazy: () => import('./routes/users/edit').then(convert(queryClient)),
                },
                {
                  path: 'project-permissions/edit',
                  lazy: () => import('./routes/users/project-permissions').then(convert(queryClient)),
                },
              ]
            },
            {
              path: 'new',
              lazy: () => import('./routes/users/new').then(convert(queryClient)),
            },
          ]
        },
        {
          path: 'settings',
          children: [
            {
              index: true,
              lazy: () => import('./routes/settings/settings').then(convert(queryClient))
            },
            {
              path: 'project-permissions',
              lazy: () => import('./routes/settings/project-permissions').then(convert(queryClient))
            },
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
