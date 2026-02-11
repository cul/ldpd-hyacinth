import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  buildUser,
  mockApi,
  renderApp,
  screen,
} from '@/testing/test-utils';
import UserProjectsRoute from '@/app/routes/users/project-permissions';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

// Helper to set up mocks that UserProjectPermissionsForm requires.
// The form calls useUser, useUserProjects, useProjects and useUsers internally.
const mockNonAdminPermissionsAPIs = (
  userUid: string,
  {
    permissions = [],
    projects = [],
    users = [],
  }: {
    permissions?: unknown[];
    projects?: unknown[];
    users?: unknown[];
  } = {},
) => {
  const user = buildUser({ uid: userUid, isAdmin: false });

  mockApi('get', `/users/${userUid}`, { user });
  mockApi('get', `/users/${userUid}/project_permissions`, { projectPermissions: permissions });
  mockApi('get', '/projects', { projects });
  mockApi('get', '/users', { users: [user, ...users] });

  return user;
};

describe('User Project Permissions Route', () => {
  describe('when user is an admin', () => {
    it('should display admin info message', async () => {
      const adminUser = buildUser({ uid: 'admin-user', isAdmin: true });

      mockApi('get', '/users/admin-user', { user: adminUser });

      await renderApp(<UserProjectsRoute />, {
        path: '/users/:userUid/project-permissions/edit',
        url: '/users/admin-user/project-permissions/edit',
      });

      expect(await screen.findByText('Admin User')).toBeInTheDocument();
      expect(
        screen.getByText(/admins have full permissions for all projects/i),
      ).toBeInTheDocument();
    });

    it('should not display the permissions form', async () => {
      const adminUser = buildUser({ uid: 'admin-user', isAdmin: true });

      mockApi('get', '/users/admin-user', { user: adminUser });

      await renderApp(<UserProjectsRoute />, {
        path: '/users/:userUid/project-permissions/edit',
        url: '/users/admin-user/project-permissions/edit',
      });

      await screen.findByText('Admin User');

      expect(
        screen.queryByRole('button', { name: /save changes/i }),
      ).not.toBeInTheDocument();
    });
  });

  describe('when user is not an admin', () => {
    it('should not show the admin info message', async () => {
      mockNonAdminPermissionsAPIs('regular-user');

      await renderApp(<UserProjectsRoute />, {
        path: '/users/:userUid/project-permissions/edit',
        url: '/users/regular-user/project-permissions/edit',
      });

      // Wait for the form to render (Save Changes button is always present)
      await screen.findByRole('button', { name: /save changes/i });

      expect(screen.queryByText('Admin User')).not.toBeInTheDocument();
    });

    it('should display empty state when user has no permissions', async () => {
      mockNonAdminPermissionsAPIs('regular-user');

      await renderApp(<UserProjectsRoute />, {
        path: '/users/:userUid/project-permissions/edit',
        url: '/users/regular-user/project-permissions/edit',
      });

      expect(
        await screen.findByText(/no project permissions assigned/i),
      ).toBeInTheDocument();
    });

    it('should display existing project permissions in the table', async () => {
      const permissions = [
        {
          projectId: 1,
          projectDisplayLabel: 'Test Project One',
          projectStringKey: 'test-project-one',
          canRead: true,
          canUpdate: true,
          canCreate: false,
          canDelete: false,
          canPublish: false,
          isProjectAdmin: false,
        },
        {
          projectId: 2,
          projectDisplayLabel: 'Test Project Two',
          projectStringKey: 'test-project-two',
          canRead: true,
          canUpdate: false,
          canCreate: false,
          canDelete: false,
          canPublish: false,
          isProjectAdmin: false,
        },
      ];

      mockNonAdminPermissionsAPIs('regular-user', { permissions });

      await renderApp(<UserProjectsRoute />, {
        path: '/users/:userUid/project-permissions/edit',
        url: '/users/regular-user/project-permissions/edit',
      });

      expect(await screen.findByText('Test Project One')).toBeInTheDocument();
      expect(screen.getByText('Test Project Two')).toBeInTheDocument();
    });

    it('should display correct column headers in the permissions table', async () => {
      mockNonAdminPermissionsAPIs('regular-user');

      await renderApp(<UserProjectsRoute />, {
        path: '/users/:userUid/project-permissions/edit',
        url: '/users/regular-user/project-permissions/edit',
      });

      await screen.findByRole('button', { name: /save changes/i });

      const expectedColumns = [
        'Project',
        'Read',
        'Update',
        'Create',
        'Delete',
        'Publish',
        'Project Admin',
        'Actions',
      ];

      for (const columnName of expectedColumns) {
        expect(screen.getByRole('columnheader', { name: columnName })).toBeInTheDocument();
      }
    });

    it('should display the Save Changes button', async () => {
      mockNonAdminPermissionsAPIs('regular-user');

      await renderApp(<UserProjectsRoute />, {
        path: '/users/:userUid/project-permissions/edit',
        url: '/users/regular-user/project-permissions/edit',
      });

      expect(
        await screen.findByRole('button', { name: /save changes/i }),
      ).toBeInTheDocument();
    });
  });
});