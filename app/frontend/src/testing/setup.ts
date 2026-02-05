import { beforeAll, afterEach, afterAll } from 'vitest';
import '@testing-library/jest-dom/vitest';
import { server } from './mocks/server';
import { db } from './mocks/db';
import { setAuthenticatedUser } from './mocks/handlers/users';

// Start MSW server before all tests
beforeAll(() => {
  server.listen({ onUnhandledRequest: 'warn' });
});

// Reset handlers and clear database after each test
afterEach(() => {
  server.resetHandlers();
  db.user.clear();
  setAuthenticatedUser(null);
});

// Close MSW server after all tests
afterAll(() => {
  server.close();
});
