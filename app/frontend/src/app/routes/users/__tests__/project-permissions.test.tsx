import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  buildUser,
  buildProjectPermission,
  mockApi,
  renderApp,
  screen,
  userEvent,
  within,
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
    describe('rendering', () => {
      it('should not show the admin info message', async () => {
        mockNonAdminPermissionsAPIs('regular-user');

        await renderApp(<UserProjectsRoute />, {
          path: '/users/:userUid/project-permissions/edit',
          url: '/users/regular-user/project-permissions/edit',
        });

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
          buildProjectPermission({ projectId: 1, projectDisplayLabel: 'Test Project One' }),
          buildProjectPermission({ projectId: 2, projectDisplayLabel: 'Test Project Two', projectStringKey: 'test-project-beta' }),
        ];

        mockNonAdminPermissionsAPIs('regular-user', { permissions });

        await renderApp(<UserProjectsRoute />, {
          path: '/users/:userUid/project-permissions/edit',
          url: '/users/regular-user/project-permissions/edit',
        });

        expect(await screen.findByText('Test Project One')).toBeInTheDocument();
        expect(screen.getByText('Test Project Two')).toBeInTheDocument();
      });

      it('should display correct column headers', async () => {
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
    });

    describe('editing permissions', () => {
      it('should show unsaved changes message after toggling a permission', async () => {
        const permissions = [buildProjectPermission({ canUpdate: false })];

        mockNonAdminPermissionsAPIs('regular-user', { permissions });

        await renderApp(<UserProjectsRoute />, {
          path: '/users/:userUid/project-permissions/edit',
          url: '/users/regular-user/project-permissions/edit',
        });

        await screen.findByText('Test Project Alpha');

        const row = screen.getByText('Test Project Alpha').closest('tr')!;
        const checkboxes = within(row).getAllByRole('checkbox');
        // Columns: Read (disabled), Update, Create, Delete, Publish, Project Admin
        const updateCheckbox = checkboxes[1];

        await userEvent.click(updateCheckbox);

        expect(screen.getByText(/you have unsaved changes/i)).toBeInTheDocument();
      });

      it('should show success alert after saving permission changes', async () => {
        const permissions = [buildProjectPermission()];

        mockNonAdminPermissionsAPIs('regular-user', { permissions });
        mockApi('put', '/users/regular-user/project_permissions', {
          projectPermissions: [buildProjectPermission({ canUpdate: true })],
        });

        await renderApp(<UserProjectsRoute />, {
          path: '/users/:userUid/project-permissions/edit',
          url: '/users/regular-user/project-permissions/edit',
        });

        await screen.findByText('Test Project Alpha');

        // Toggle a permission to enable the Save button
        const row = screen.getByText('Test Project Alpha').closest('tr')!;
        const checkboxes = within(row).getAllByRole('checkbox');
        await userEvent.click(checkboxes[1]);

        await userEvent.click(screen.getByRole('button', { name: /save changes/i }));

        expect(
          await screen.findByText(/permissions saved successfully/i),
        ).toBeInTheDocument();
      });

      it('should show error alert when saving fails', async () => {
        const permissions = [buildProjectPermission()];

        mockNonAdminPermissionsAPIs('regular-user', { permissions });
        mockApi('put', '/users/regular-user/project_permissions', { error: 'Save failed' }, 422);

        await renderApp(<UserProjectsRoute />, {
          path: '/users/:userUid/project-permissions/edit',
          url: '/users/regular-user/project-permissions/edit',
        });

        await screen.findByText('Test Project Alpha');

        const row = screen.getByText('Test Project Alpha').closest('tr')!;
        const checkboxes = within(row).getAllByRole('checkbox');
        await userEvent.click(checkboxes[1]);

        await userEvent.click(screen.getByRole('button', { name: /save changes/i }));

        expect(
          await screen.findByText(/error saving permissions/i),
        ).toBeInTheDocument();
      });
    });

    describe('removing permissions', () => {
      it('should remove a project row when clicking Delete', async () => {
        const permissions = [
          buildProjectPermission({ projectId: 1, projectDisplayLabel: 'Project To Keep', projectStringKey: 'keep' }),
          buildProjectPermission({ projectId: 2, projectDisplayLabel: 'Project To Remove', projectStringKey: 'remove' }),
        ];

        mockNonAdminPermissionsAPIs('regular-user', { permissions });

        await renderApp(<UserProjectsRoute />, {
          path: '/users/:userUid/project-permissions/edit',
          url: '/users/regular-user/project-permissions/edit',
        });

        await screen.findByText('Project To Remove');

        const row = screen.getByText('Project To Remove').closest('tr')!;
        await userEvent.click(within(row).getByRole('button', { name: /delete/i }));

        expect(screen.queryByText('Project To Remove')).not.toBeInTheDocument();
        expect(screen.getByText('Project To Keep')).toBeInTheDocument();
        expect(screen.getByText(/you have unsaved changes/i)).toBeInTheDocument();
      });
    });
  });
});