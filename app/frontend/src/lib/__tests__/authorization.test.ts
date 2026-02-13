import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import { QueryClient } from '@tanstack/react-query';
import {
  buildUser,
  mockApi,
  renderWithRoutes,
  screen,
} from '@/testing/test-utils';
import { AuthorizationErrorBoundary } from '@/components/errors/authorization-error';

import * as UsersIndexModule from '@/app/routes/users/index';
import * as UsersEditModule from '@/app/routes/users/edit';
import * as UsersNewModule from '@/app/routes/users/new';
import * as UsersProjectPermissionsModule from '@/app/routes/users/project-permissions';
import * as SettingsModule from '@/app/routes/settings';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

/*
  Integration tests for route-level authorization, which verify that users without the required roles see an authorization error
  when trying to access protected routes, and that users with the required roles can access those routes successfully.
*/
describe('Users route authorization', () => {
  describe('when user is not an admin', () => {
    it('should show authorization error on /users', async () => {
      const regularUser = buildUser({ uid: 'regular', isAdmin: false });

      await renderWithRoutes(
        (queryClient: QueryClient) => [
          {
            path: '/users',
            loader: UsersIndexModule.clientLoader(queryClient),
            Component: UsersIndexModule.default,
            ErrorBoundary: AuthorizationErrorBoundary,
          },
        ],
        { user: regularUser, url: '/users' },
      );

      expect(await screen.findByText(/access denied/i)).toBeInTheDocument();
    });

    it('should show authorization error on /users/new', async () => {
      const regularUser = buildUser({ uid: 'regular', isAdmin: false });

      await renderWithRoutes(
        (queryClient: QueryClient) => [
          {
            path: '/users/new',
            loader: UsersNewModule.clientLoader(queryClient),
            Component: UsersNewModule.default,
            ErrorBoundary: AuthorizationErrorBoundary,
          },
        ],
        { user: regularUser, url: '/users/new' },
      );

      expect(await screen.findByText(/access denied/i)).toBeInTheDocument();
    });

    it('should show authorization error on /users/:userUid/edit', async () => {
      const regularUser = buildUser({ uid: 'regular', isAdmin: false });

      await renderWithRoutes(
        (queryClient: QueryClient) => [
          {
            path: '/users/:userUid/edit',
            loader: UsersEditModule.clientLoader(queryClient),
            Component: UsersEditModule.default,
            ErrorBoundary: AuthorizationErrorBoundary,
          },
        ],
        { user: regularUser, url: '/users/someone/edit' },
      );

      expect(await screen.findByText(/access denied/i)).toBeInTheDocument();
    });

    it('should show authorization error on /users/:userUid/project-permissions/edit', async () => {
      const regularUser = buildUser({ uid: 'regular', isAdmin: false });

      await renderWithRoutes(
        (queryClient: QueryClient) => [
          {
            path: '/users/:userUid/project-permissions/edit',
            loader: UsersProjectPermissionsModule.clientLoader(queryClient),
            Component: UsersProjectPermissionsModule.default,
            ErrorBoundary: AuthorizationErrorBoundary,
          },
        ],
        { user: regularUser, url: '/users/someone/project-permissions/edit' },
      );

      expect(await screen.findByText(/access denied/i)).toBeInTheDocument();
    });
  });

  describe('when user is an admin', () => {
    it('should render the users list on /users', async () => {
      const adminUser = buildUser({ uid: 'admin', isAdmin: true });

      mockApi('get', '/users', { users: [adminUser] });

      await renderWithRoutes(
        (queryClient: QueryClient) => [
          {
            path: '/users',
            loader: UsersIndexModule.clientLoader(queryClient),
            Component: UsersIndexModule.default,
            ErrorBoundary: AuthorizationErrorBoundary,
          },
        ],
        { user: adminUser, url: '/users' },
      );

      expect(await screen.findByText('admin')).toBeInTheDocument();
    });
  });

  describe('edit route self-redirect', () => {
    it('should redirect to /settings when admin tries to edit themselves', async () => {
      const adminUser = buildUser({ uid: 'myself', isAdmin: true });

      await renderWithRoutes(
        (queryClient: QueryClient) => [
          {
            path: '/users/:userUid/edit',
            loader: UsersEditModule.clientLoader(queryClient),
            Component: UsersEditModule.default,
            ErrorBoundary: AuthorizationErrorBoundary,
          },
          {
            path: '/settings',
            Component: SettingsModule.default,
          },
        ],
        { user: adminUser, url: '/users/myself/edit' },
      );

      expect(await screen.findByText('My Settings')).toBeInTheDocument();
    });
  });
});