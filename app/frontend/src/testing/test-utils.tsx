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
import { db } from '@/testing/mocks/db';
import { createUser as generateUser } from './data-generators';
import { setAuthenticatedUser } from './mocks/handlers/users';
import { AUTH_QUERY_KEY } from '@/lib/auth';
import type { User } from '@/types/api';

const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        gcTime: Infinity,
      },
    },
  });

export const createUser = (userProperties?: Partial<User>): User => {
  const user = generateUser(userProperties) as User;
  db.user.create({ ...user });
  return user;
};

export const loginAsUser = (user: User) => {
  setAuthenticatedUser(user.uid);
  return user;
};

export const logout = () => {
  setAuthenticatedUser(null);
};

const initializeUser = (user?: User | null) => {
  if (user === null) {
    // Explicitly unauthenticated
    return null;
  }

  if (typeof user === 'undefined') {
    // Create and login a default user
    const newUser = createUser();
    return loginAsUser(newUser);
  }

  // Login the provided user
  return loginAsUser(user);
};

export const renderApp = async (
  ui: React.ReactElement,
  { user, url = '/', path = '/', ...renderOptions }: Record<string, any> = {},
) => {
  // If you want to render the app unauthenticated then pass "null" as the user
  const initializedUser = initializeUser(user);

  const queryClient = createTestQueryClient();

  // Keeps the history of your "URL" in memory (does not read or write to the address bar)
  const router = createMemoryRouter(
    [
      {
        path: path,
        element: ui,
      },
    ],
    {
      initialEntries: url ? ['/', url] : ['/'],
      initialIndex: url ? 1 : 0,
    },
  );

  const returnValue = {
    user: initializedUser,
    ...rtlRender(
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>,
      renderOptions,
    ),
  };

  return returnValue;
};

// Render with custom routes - useful for testing loaders, error boundaries, etc.
// The routesFactory receives the queryClient so loaders can be properly initialized
export const renderWithRoutes = async (
  routesFactory: (queryClient: QueryClient) => RouteObject[],
  {
    user,
    url = '/',
    ...renderOptions
  }: { user?: User | null; url?: string; [key: string]: unknown } = {},
) => {
  const initializedUser = initializeUser(user);

  const queryClient = createTestQueryClient();

  // Pre-populate the auth query cache so loaders can access the user
  if (initializedUser) {
    queryClient.setQueryData(AUTH_QUERY_KEY, initializedUser);
  }

  const routes = routesFactory(queryClient);

  const router = createMemoryRouter(routes, {
    initialEntries: [url],
  });

  const returnValue = {
    user: initializedUser,
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
