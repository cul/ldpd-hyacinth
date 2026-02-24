import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  buildUser,
  mockApiV2,
  renderApp,
  screen,
  userEvent,
} from '@/testing/test-utils';
import SettingsIndexRoute from '@/app/routes/settings';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});  

afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('Settings Index Route', () => {
  describe('rendering', () => {
    it('should render the user form populated with the current user data', async () => {
      const user = buildUser({
        uid: 'currentuser',
        firstName: 'Current',
        lastName: 'User',
        email: 'currentuser@example.com',
      });

      mockApiV2('get', '/users/_self', { user });

      await renderApp(<SettingsIndexRoute />, { url: '/settings' });

      expect(await screen.findByDisplayValue('Current')).toBeInTheDocument();
      expect(screen.getByDisplayValue('User')).toBeInTheDocument();
      expect(screen.getByDisplayValue('currentuser@example.com')).toBeInTheDocument();
    });

    it('should disable UID, Is Active and permission checkboxes when editing own settings', async () => {
      const user = buildUser({
        uid: 'currentuser',
        isAdmin: false,
      });

      mockApiV2('get', '/users/_self', { user });

      await renderApp(<SettingsIndexRoute />, { url: '/settings' });

      expect(await screen.findByDisplayValue('currentuser')).toBeDisabled();
      expect(screen.getByLabelText(/is active/i)).toBeDisabled();
      expect(screen.getByLabelText(/is admin/i)).toBeDisabled();
      expect(screen.getByLabelText(/can manage controlled vocabularies/i)).toBeDisabled();
    });

    it('should render the API key generation section', async () => {
      const user = buildUser({
        uid: 'currentuser',
        isAdmin: false,
        apiKeyDigest: null
      });

      mockApiV2('get', '/users/_self', { user });

      await renderApp(<SettingsIndexRoute />, { url: '/settings' });

      expect(await screen.findByRole('button', { name: /generate api key/i }),).toBeInTheDocument();
      expect(screen.getByText(/api key has not been generated/i),).toBeInTheDocument();
    });
  });

  describe('non-admin user', () => {
    it('should disable email and account type fields', async () => {
      const user = buildUser({
        uid: 'currentuser',
        isAdmin: false,
      });

      mockApiV2('get', '/users/_self', { user });

      await renderApp(<SettingsIndexRoute />, { url: '/settings' });

      await screen.findByDisplayValue('currentuser');
      expect(await screen.findByLabelText(/email/i)).toBeDisabled();
      expect(screen.getByLabelText(/account type/i)).toBeDisabled();
    });

    it('should allow editing first and last name', async () => {
      const user = buildUser({
        uid: 'currentuser',
        isAdmin: false,
        firstName: 'Current',
        lastName: 'User',
      });

      mockApiV2('get', '/users/_self', { user });

      await renderApp(<SettingsIndexRoute />, { url: '/settings' });
      
      const firstNameInput = await screen.findByDisplayValue('Current');
      const lastNameInput = screen.getByDisplayValue('User');

      expect(firstNameInput).toBeEnabled();
      expect(lastNameInput).toBeEnabled();
    });
  });

  describe('saving changes', () => {
    it('should show success message on successful update', async () => {
      const user = buildUser({
        uid: 'currentuser',
        isAdmin: false,
        firstName: 'Current',
        lastName: 'User',
      });

      mockApiV2('get', '/users/_self', { user });
      mockApiV2('patch', '/users/currentuser', { user: { ...user, firstName: 'Updated' } });

      await renderApp(<SettingsIndexRoute />, { url: '/settings' });

      const firstNameInput = await screen.findByDisplayValue('Current');

      await userEvent.clear(firstNameInput);
      await userEvent.type(firstNameInput, 'Updated');

      await userEvent.click(screen.getByRole('button', { name: /save/i }));

      expect(await screen.findByText(/user updated successfully/i)).toBeInTheDocument();
    });

    it('should show error message on update failure', async () => {
      const user = buildUser({
        uid: 'currentuser',
        isAdmin: false,
        firstName: 'Current',
        lastName: 'User',
      });

      mockApiV2('get', '/users/_self', { user });
      mockApiV2('patch', '/users/currentuser', { message: 'Update failed' }, 422);

      await renderApp(<SettingsIndexRoute />, { url: '/settings' });

      const firstNameInput = await screen.findByDisplayValue('Current');

      await userEvent.clear(firstNameInput);
      await userEvent.type(firstNameInput, 'Updated');

      await userEvent.click(screen.getByRole('button', { name: /save/i }));

      expect(await screen.findByText(/error updating user/i)).toBeInTheDocument();
    });
  });
});