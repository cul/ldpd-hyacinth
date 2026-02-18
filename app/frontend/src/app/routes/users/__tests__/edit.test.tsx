import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  buildUser,
  mockApi,
  renderApp,
  screen,
  userEvent,
} from '@/testing/test-utils';
import UsersEditRoute from '@/app/routes/users/edit';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('Users Edit Route', () => {
  describe('rendering', () => {
    it('should render the user form populated with data from the API', async () => {
      const user = buildUser({
        uid: 'janedoe',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        isAdmin: false,
        isActive: true,
        canManageAllControlledVocabularies: false,
        accountType: 'standard',
      });

      mockApi('get', '/users/janedoe', { user });

      await renderApp(<UsersEditRoute />, {
        path: '/users/:userUid/edit',
        url: '/users/janedoe/edit',
      });

      expect(await screen.findByDisplayValue('Jane')).toBeInTheDocument();
      expect(screen.getByDisplayValue('Doe')).toBeInTheDocument();
      expect(screen.getByDisplayValue('jane@example.com')).toBeInTheDocument();
    });

    it('should disable the UID field in edit mode', async () => {
      const user = buildUser({ uid: 'janedoe' });

      mockApi('get', '/users/janedoe', { user });

      await renderApp(<UsersEditRoute />, {
        path: '/users/:userUid/edit',
        url: '/users/janedoe/edit',
      });

      const uidInput = await screen.findByDisplayValue('janedoe');
      expect(uidInput).toBeDisabled();
    });
  });

  describe('updating a user', () => {
    it('should show success alert after saving changes', async () => {
      const user = buildUser({
        uid: 'janedoe',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
      });

      mockApi('get', '/users/janedoe', { user });
      mockApi('patch', '/users/janedoe', {
        user: { ...user, firstName: 'Janet' },
      });

      await renderApp(<UsersEditRoute />, {
        path: '/users/:userUid/edit',
        url: '/users/janedoe/edit',
      });

      const firstNameInput = await screen.findByDisplayValue('Jane');

      await userEvent.clear(firstNameInput);
      await userEvent.type(firstNameInput, 'Janet');

      await userEvent.click(screen.getByRole('button', { name: 'Save' }));

      expect(
        await screen.findByText(/user updated successfully/i),
      ).toBeInTheDocument();
    });

    it('should show error alert when update fails', async () => {
      const user = buildUser({
        uid: 'janedoe',
        firstName: 'Jane',
        lastName: 'Doe',
      });

      mockApi('get', '/users/janedoe', { user });
      mockApi('patch', '/users/janedoe', { error: 'Update failed' }, 422);

      await renderApp(<UsersEditRoute />, {
        path: '/users/:userUid/edit',
        url: '/users/janedoe/edit',
      });

      await screen.findByDisplayValue('Jane');

      await userEvent.click(screen.getByRole('button', { name: 'Save' }));

      expect(
        await screen.findByText(/error updating user/i),
      ).toBeInTheDocument();
    });
  });

  describe('API key generation', () => {
    it('should show "Generate API Key" when no key exists', async () => {
      const user = buildUser({ uid: 'janedoe', apiKeyDigest: null });

      mockApi('get', '/users/janedoe', { user });

      await renderApp(<UsersEditRoute />, {
        path: '/users/:userUid/edit',
        url: '/users/janedoe/edit',
      });

      expect(
        await screen.findByText(/api key has not been generated/i),
      ).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: /generate api key/i }),
      ).toBeInTheDocument();
    });

    it('should show "Regenerate API Key" when a key already exists', async () => {
      const user = buildUser({ uid: 'janedoe', apiKeyDigest: 'abc123digest' });

      mockApi('get', '/users/janedoe', { user });

      await renderApp(<UsersEditRoute />, {
        path: '/users/:userUid/edit',
        url: '/users/janedoe/edit',
      });

      expect(
        await screen.findByText(/an api key is currently set/i),
      ).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: /regenerate api key/i }),
      ).toBeInTheDocument();
    });

    it('should display the new API key after generation', async () => {
      const user = buildUser({ uid: 'janedoe', apiKeyDigest: null });

      mockApi('get', '/users/janedoe', { user });
      mockApi('post', '/users/janedoe/generate_new_api_key', {
        apiKey: 'new-secret-key-12345',
      });

      await renderApp(<UsersEditRoute />, {
        path: '/users/:userUid/edit',
        url: '/users/janedoe/edit',
      });

      await userEvent.click(
        await screen.findByRole('button', { name: /generate api key/i }),
      );

      expect(
        await screen.findByText('new-secret-key-12345'),
      ).toBeInTheDocument();
      expect(
        screen.getByText(/please copy this api key now/i),
      ).toBeInTheDocument();
    });
  });
});