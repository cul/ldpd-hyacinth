import { describe, it, expect, vi, beforeAll, afterAll, type Mock, beforeEach } from 'vitest';
import {
  buildUser,
  mockApi,
  renderApp,
  screen,
  userEvent,
} from '@/testing/test-utils';
import UsersNewRoute from '@/app/routes/users/new';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});


afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('Users New Route', () => {
  beforeEach(async () => {
    await renderApp(<UsersNewRoute />, {
      path: '/users/new',
      url: '/users/new',
    });
  });

  it('should render an empty user creation form', async () => {
    expect(screen.getByLabelText(/uid/i)).toHaveValue('');
    expect(screen.getByLabelText(/first name/i)).toHaveValue('');
    expect(screen.getByLabelText(/last name/i)).toHaveValue('');
    expect(screen.getByLabelText(/email/i)).toHaveValue('');
    expect(screen.getByLabelText(/account type/i)).toHaveValue('');
  });

  it('should keep the UID field enabled in creation mode', async () => {
    const uidInput = await screen.findByLabelText(/uid/i);
    expect(uidInput).toBeEnabled();
  });

  it('should show the account type placeholder option', async () => {
    expect(
      await screen.findByRole('option', { name: /choose account type/i }),
    ).toBeInTheDocument();
  });

  it('should default checkboxes to unchecked except Is Active', async () => {
    expect(screen.getByLabelText(/is active/i)).toBeChecked();
    expect(screen.getByLabelText(/is admin/i)).not.toBeChecked();
    expect(screen.getByLabelText(/can manage controlled vocabularies/i)).not.toBeChecked();
  });

  it('should show success alert after filling out and submitting the form', async () => {
    const newUser = buildUser({
      uid: 'newuser',
      firstName: 'New',
      lastName: 'User',
      email: 'new@example.com',
      accountType: 'standard',
    });

    mockApi('post', '/users', { user: newUser }, 201);

    await userEvent.type(screen.getByLabelText(/uid/i), 'newuser');
    await userEvent.type(screen.getByLabelText(/first name/i), 'New');
    await userEvent.type(screen.getByLabelText(/last name/i), 'User');
    await userEvent.type(screen.getByLabelText(/email/i), 'new@example.com');

    // Select account type from dropdown
    await userEvent.selectOptions(
      screen.getByLabelText(/account type/i),
      'standard',
    );

    await userEvent.click(screen.getByRole('button', { name: 'Save' }));

    expect(
      await screen.findByText(/user created successfully/i),
    ).toBeInTheDocument();
  });

  it('should show error alert when creation fails', async () => {
    mockApi('post', '/users', { error: 'UID already taken' }, 422);

    // Fill minimum required fields
    await userEvent.type(screen.getByLabelText(/uid/i), 'duplicate');
    await userEvent.type(screen.getByLabelText(/first name/i), 'Test');
    await userEvent.type(screen.getByLabelText(/last name/i), 'User');
    await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');

    await userEvent.click(screen.getByRole('button', { name: 'Save' }));

    expect(
      await screen.findByText(/error creating user/i),
    ).toBeInTheDocument();
  });
});
