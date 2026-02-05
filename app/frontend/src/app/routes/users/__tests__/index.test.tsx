// Integration test file for users index route
import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  createUser,
  renderApp,
  screen,
  within,
} from '@/testing/test-utils';
import UsersList from '@/features/users/components/users-list';
import UsersLayout from '@/components/layouts/users-layout';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => {});
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('Users Index Route', () => {
  it('should display users list in a table with correct data from API', async () => {
    // Create test users in the mock database
    const user1 = createUser({
      uid: 'johndoe',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      isAdmin: true,
      isActive: true,
      canManageAllControlledVocabularies: true,
      accountType: 'standard',
    });

    const _user2 = createUser({
      uid: 'hyacinthservice',
      firstName: 'Hyacinth',
      lastName: 'Service',
      email: 'hyacinth.service@example.com',
      isAdmin: false,
      isActive: true,
      canManageAllControlledVocabularies: false,
      accountType: 'service',
    });

    await renderApp(<UsersList />, { user: user1, path: '/users', url: '/users' });

    // Wait for users to be loaded and rendered
    expect(await screen.findByText('johndoe')).toBeInTheDocument();
    expect(await screen.findByText('hyacinthservice')).toBeInTheDocument();

    // Check user data is rendered correctly
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('Hyacinth Service')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
    expect(screen.getByText('hyacinth.service@example.com')).toBeInTheDocument();
  });

  it('should display correct column headers', async () => {
    const user = createUser({ uid: 'test-user' });
    await renderApp(<UsersList />, { user, path: '/users', url: '/users' });

    await screen.findByRole('table');

    const expectedColumns = [
      'UID',
      'Name',
      'Email',
      'Is Admin',
      'Can Manage Vocabularies',
      'Account Type',
      'Is Active',
    ];

    for (const columnName of expectedColumns) {
      expect(screen.getByRole('columnheader', { name: columnName })).toBeInTheDocument();
    }
  });

  it('should display data sorted in ascending order by UID', async () => {
    // Create users with different UIDs
    createUser({
      uid: 'charlie',
      firstName: 'Charlie',
      lastName: 'Clark',
      email: 'charlie@example.com',
    });

    createUser({
      uid: 'alice',
      firstName: 'Alice',
      lastName: 'Anderson',
      email: 'alice@example.com',
    });

    createUser({
      uid: 'bob',
      firstName: 'Bob',
      lastName: 'Brown',
      email: 'bob@example.com',
    });

    await renderApp(<UsersList />, { user: null, path: '/users', url: '/users' });

    await screen.findByRole('table');

    // Get all cells in UID column and verify ascending order
    const rows = screen.getAllByRole('row');
    // Skip header row
    const uidCells = rows.slice(1).map((row) => within(row).getAllByRole('cell')[0]);
    const uids = uidCells.map((cell) => cell.textContent);

    // Should be sorted ascending by UID
    expect(uids).toEqual(['alice', 'bob', 'charlie']);
  });

  it('should render UID as a link to the edit user page', async () => {
    const user = createUser({
      uid: 'test-user-uid',
      firstName: 'Test',
      lastName: 'User',
    });

    await renderApp(<UsersList />, { user, path: '/users', url: '/users' });

    const uidLink = await screen.findByRole('link', { name: 'test-user-uid' });

    expect(uidLink).toBeInTheDocument();
    expect(uidLink).toHaveAttribute('href', '/users/test-user-uid/edit');
  });

  // ? Should this be moved to a different test file since it's about the layout?
  it('should display the Create New User button', async () => {
    const user = createUser({ uid: 'admin-user' });

    await renderApp(<UsersLayout />, { user, path: '/users', url: '/users' });

    const createButton = await screen.findByRole('button', { name: /create new user/i });

    expect(createButton).toBeInTheDocument();
  });
});

