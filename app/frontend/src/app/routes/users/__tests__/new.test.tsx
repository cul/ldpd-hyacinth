import { describe, it, expect, vi, beforeAll, afterAll, type Mock, beforeEach } from 'vitest';
import {
  renderApp,
  screen,
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
    // In creation mode the select shows a placeholder that is absent in edit mode
    expect(
      await screen.findByRole('option', { name: /choose account type/i }),
    ).toBeInTheDocument();
  });

  it('should default checkboxes to unchecked except Is Active', async () => {
    expect(await screen.findByLabelText(/is active/i)).toBeChecked();
    expect(screen.getByLabelText(/is admin/i)).not.toBeChecked();
    expect(screen.getByLabelText(/can manage controlled vocabularies/i)).not.toBeChecked();
  });

  it('should display the Save button', async () => {
    expect(
      await screen.findByRole('button', { name: 'Save' }),
    ).toBeInTheDocument();
  });
});
