import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  buildUser,
  mockApi,
  renderApp,
  screen,
} from '@/testing/test-utils';
import UsersEditRoute from '@/app/routes/users/edit';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('Users Edit Route', () => {
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

    // UserForm renders controlled inputs — verify they are populated
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

  it('should render the API key generation section', async () => {
    const user = buildUser({ uid: 'janedoe', apiKeyDigest: null });

    mockApi('get', '/users/janedoe', { user });

    await renderApp(<UsersEditRoute />, {
      path: '/users/:userUid/edit',
      url: '/users/janedoe/edit',
    });

    expect(
      await screen.findByText(/api key generation/i),
    ).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: /generate api key/i }),
    ).toBeInTheDocument();
  });

  it('should show existing API key warning when user has an API key', async () => {
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

  it('should display the Save button', async () => {
    const user = buildUser({ uid: 'janedoe' });

    mockApi('get', '/users/janedoe', { user });

    await renderApp(<UsersEditRoute />, {
      path: '/users/:userUid/edit',
      url: '/users/janedoe/edit',
    });

    expect(
      await screen.findByRole('button', { name: 'Save' }),
    ).toBeInTheDocument();
  });
});