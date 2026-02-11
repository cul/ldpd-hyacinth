import { describe, it, expect, vi, beforeAll, afterAll, type Mock } from 'vitest';
import {
  buildUser,
  mockApi,
  renderApp,
  screen,
  within,
} from '@/testing/test-utils';
import UsersList from '@/features/users/components/users-list';
import UsersLayout from '@/components/layouts/users-layout';

beforeAll(() => {
  vi.spyOn(console, 'error').mockImplementation(() => { });
});

afterAll(() => {
  (console.error as Mock).mockRestore();
});

describe('Users Index Route', () => {
  it('should display users list in a table with correct data from API', async () => {
    const user1 = buildUser({
      uid: 'johndoe',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
    });

    const user2 = buildUser({
      uid: 'hyacinthservice',
      firstName: 'Hyacinth',
      lastName: 'Service',
      email: 'hyacinth.service@example.com',
    });

    mockApi('get', '/users', { users: [user1, user2] });

    await renderApp(<UsersList />, { path: '/users', url: '/users' });

    expect(await screen.findByText('johndoe')).toBeInTheDocument();
    expect(await screen.findByText('hyacinthservice')).toBeInTheDocument();

    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('Hyacinth Service')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
    expect(screen.getByText('hyacinth.service@example.com')).toBeInTheDocument();
  });

  it('should display correct column headers', async () => {
    const user = buildUser({ uid: 'test-user' });

    mockApi('get', '/users', { users: [user] });

    await renderApp(<UsersList />, { path: '/users', url: '/users' });

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
    const alice = buildUser({ uid: 'alice', firstName: 'Alice', lastName: 'Anderson', email: 'alice@example.com' });
    const charlie = buildUser({ uid: 'charlie', firstName: 'Charlie', lastName: 'Clark', email: 'charlie@example.com' });
    const bob = buildUser({ uid: 'bob', firstName: 'Bob', lastName: 'Brown', email: 'bob@example.com' });

    mockApi('get', '/users', { users: [alice, bob, charlie] });

    await renderApp(<UsersList />, { path: '/users', url: '/users' });

    await screen.findByRole('table');

    const rows = screen.getAllByRole('row');
    const uids = rows.slice(1).map((row) => within(row).getAllByRole('cell')[0].textContent);

    expect(uids).toEqual(['alice', 'bob', 'charlie']);
  });

  it('should render UID as a link to the edit user page', async () => {
    const user = buildUser({ uid: 'test-user-uid', firstName: 'Test', lastName: 'User' });

    mockApi('get', '/users', { users: [user] });

    await renderApp(<UsersList />, { path: '/users', url: '/users' });

    const uidLink = await screen.findByRole('link', { name: 'test-user-uid' });

    expect(uidLink).toBeInTheDocument();
    expect(uidLink).toHaveAttribute('href', '/users/test-user-uid/edit');
  });

  it('should display the Create New User button', async () => {
    const user = buildUser({ uid: 'admin-user' });

    mockApi('get', '/users', { users: [user] });

    await renderApp(<UsersLayout />, { path: '/users', url: '/users' });

    const createButton = await screen.findByRole('button', { name: /create new user/i });

    expect(createButton).toBeInTheDocument();
  });
});