import React from 'react';
import {
  render as rtlRender,
  screen,
  waitForElementToBeRemoved,
  waitFor,
  within,
} from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import {
  RouterProvider,
  createMemoryRouter,
  type RouteObject,
} from 'react-router';
import { AUTH_QUERY_KEY } from '@/lib/auth';
import type { User } from '@/types/api';

export { buildUser, buildProjectPermission } from './data-generators';
export { mockApi } from './mock-api';

const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        gcTime: Infinity,
      },
    },
  });


/*
  renderApp

  Renders a component inside a QueryClient + MemoryRouter.
*/

interface RenderAppOptions {
  url?: string;
  path?: string;
  [key: string]: unknown;
}

export const renderApp = async (
  ui: React.ReactElement,
  {
    url = '/', // route pattern React Router uses for matching and resolving params (e.g. '/users/:userUid/edit')
    path = '/', // simulated browser location to navigate to (e.g. '/users/janedoe/edit')
    ...renderOptions
  }: RenderAppOptions = {},
) => {
  const queryClient = createTestQueryClient();

  const router = createMemoryRouter(
    [{ path, element: ui }],
    {
      initialEntries: url ? ['/', url] : ['/'],
      initialIndex: url ? 1 : 0,
    },
  );

  return rtlRender(
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>,
    renderOptions,
  );
};

/*
  renderWithRoutes

  For testing loaders, error boundaries, or full route trees.
  The routesFactory receives the QueryClient so loaders can prefetch data.
*/

interface RenderWithRoutesOptions {
  user?: User | null;
  url?: string;
  [key: string]: unknown;
}

export const renderWithRoutes = async (
  routesFactory: (queryClient: QueryClient) => RouteObject[],
  {
    user,
    url = '/',
    ...renderOptions
  }: RenderWithRoutesOptions = {},
) => {
  const queryClient = createTestQueryClient();

  // Pre-populate the auth query cache so loaders can access the user
  if (user) {
    queryClient.setQueryData(AUTH_QUERY_KEY, user);
  }

  const routes = routesFactory(queryClient);
  const router = createMemoryRouter(routes, {
    initialEntries: [url],
  });

  const returnValue = {
    queryClient,
    ...rtlRender(
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>,
      renderOptions,
    ),
  };

  return returnValue;
};

export * from '@testing-library/react';
export { screen, waitForElementToBeRemoved, waitFor, within, userEvent };
