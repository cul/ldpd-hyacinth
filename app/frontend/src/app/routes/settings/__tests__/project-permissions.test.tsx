import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  buildUser,
  mockApiV2,
  renderApp,
  screen,
  within,
} from '@/testing/test-utils';
import SettingsProjectPermissionsRoute from '@/app/routes/settings/project-permissions';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('Settings Project Permissions Route', () => {
  describe('when user is an admin', () => {
    it('should display admin info message', async () => {
      const adminUser = buildUser({ uid: 'adminuser', isAdmin: true });

      await renderApp(<SettingsProjectPermissionsRoute />, {
        url: '/settings/project-permissions',
        user: adminUser,
      });

      expect(await screen.findByText(/as an admin, you have full permissions for all projects/i),).toBeInTheDocument();
    });

    it('should not display the permissions table', async () => {
      const adminUser = buildUser({ uid: 'adminuser', isAdmin: true });

      await renderApp(<SettingsProjectPermissionsRoute />, {
        url: '/settings/project-permissions',
        user: adminUser,
      });

      await screen.findByText('Admin User');

      expect(screen.queryByRole('table')).not.toBeInTheDocument();
    });
  });

  describe('when user is not an admin', () => {
    it('should display the page heading', async () => {
      const user = buildUser({ uid: 'regularuser', isAdmin: false });

      mockApiV2('get', '/users/regularuser/project_permissions', { projectPermissions: [] });

      await renderApp(<SettingsProjectPermissionsRoute />, {
        url: '/settings/project-permissions',
        user,
      });

      expect(
        await screen.findByText('My Project Permissions'),
      ).toBeInTheDocument();
    });

    it('should not show the admin info message', async () => {
      const user = buildUser({ uid: 'regularuser', isAdmin: false });

      mockApiV2('get', '/users/regularuser/project_permissions', { projectPermissions: [] });

      await renderApp(<SettingsProjectPermissionsRoute />, {
        url: '/settings/project-permissions',
        user,
      });

      await screen.findByText('My Project Permissions');

      expect(screen.queryByText('Admin User')).not.toBeInTheDocument();
    });

    it('should display project permissions in a table', async () => {
      const user = buildUser({ uid: 'regularuser', isAdmin: false });

      const permissions = [
        {
          projectId: 1,
          projectDisplayLabel: 'Digital Collections',
          projectStringKey: 'digital-collections',
          canRead: true,
          canUpdate: true,
          canCreate: false,
          canDelete: false,
          canPublish: false,
          isProjectAdmin: false,
        },
        {
          projectId: 2,
          projectDisplayLabel: 'Oral Histories',
          projectStringKey: 'oral-histories',
          canRead: true,
          canUpdate: false,
          canCreate: false,
          canDelete: false,
          canPublish: false,
          isProjectAdmin: false,
        },
      ];

      mockApiV2('get', '/users/regularuser/project_permissions', { projectPermissions: permissions });

      await renderApp(<SettingsProjectPermissionsRoute />, {
        url: '/settings/project-permissions',
        user,
      });

      expect(await screen.findByText('Digital Collections')).toBeInTheDocument();
      expect(screen.getByText('Oral Histories')).toBeInTheDocument();
    });

    it('should display correct read-only column headers without Actions', async () => {
      const user = buildUser({ uid: 'regularuser', isAdmin: false });

      mockApiV2('get', '/users/regularuser/project_permissions', {
        projectPermissions: [
          {
            projectId: 1,
            projectDisplayLabel: 'Test Project',
            projectStringKey: 'test',
            canRead: true,
            canUpdate: false,
            canCreate: false,
            canDelete: false,
            canPublish: false,
            isProjectAdmin: false,
          },
        ]
      });

      await renderApp(<SettingsProjectPermissionsRoute />, {
        url: '/settings/project-permissions',
        user,
      });

      await screen.findByRole('table');

      const expectedColumns = [
        'Project',
        'Read',
        'Update',
        'Create',
        'Delete',
        'Publish',
        'Project Admin',
      ];

      for (const columnName of expectedColumns) {
        expect(screen.getByRole('columnheader', { name: columnName })).toBeInTheDocument();
      }

      // readOnlyColumnDefs should NOT include an Actions column
      expect(
        screen.queryByRole('columnheader', { name: 'Actions' }),
      ).not.toBeInTheDocument();
    });

    it('should render all permission checkboxes as disabled', async () => {
      const user = buildUser({ uid: 'regularuser', isAdmin: false });

      mockApiV2('get', '/users/regularuser/project_permissions', {
        projectPermissions: [
          {
            projectId: 1,
            projectDisplayLabel: 'Test Project',
            projectStringKey: 'test',
            canRead: true,
            canUpdate: true,
            canCreate: false,
            canDelete: false,
            canPublish: false,
            isProjectAdmin: false,
          },
        ]
      });

      await renderApp(<SettingsProjectPermissionsRoute />, {
        url: '/settings/project-permissions',
        user,
      });

      const row = (await screen.findByText('Test Project')).closest('tr')!;
      const checkboxes = within(row).getAllByRole('checkbox');

      for (const checkbox of checkboxes) {
        expect(checkbox).toBeDisabled();
      }
    });

    it('should not render any Delete buttons or Save button', async () => {
      const user = buildUser({ uid: 'regularuser', isAdmin: false });

      mockApiV2('get', '/users/regularuser/project_permissions', {
        projectPermissions: [
          {
            projectId: 1,
            projectDisplayLabel: 'Test Project',
            projectStringKey: 'test',
            canRead: true,
            canUpdate: false,
            canCreate: false,
            canDelete: false,
            canPublish: false,
            isProjectAdmin: false,
          },
        ]
      });

      await renderApp(<SettingsProjectPermissionsRoute />, {
        url: '/settings/project-permissions',
        user,
      });

      await screen.findByText('Test Project');

      expect(
        screen.queryByRole('button', { name: /delete/i }),
      ).not.toBeInTheDocument();
      expect(
        screen.queryByRole('button', { name: /save/i }),
      ).not.toBeInTheDocument();
    });
  });
});