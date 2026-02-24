import { describe, it, expect } from 'vitest';
import { QueryClient } from '@tanstack/react-query';
import { AUTH_QUERY_KEY } from '@/lib/auth';
import {
  requireAuthorization,
  isAuthorizationError,
} from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { buildUser } from '@/testing/data-generators';

const createQueryClientWithUser = (user: ReturnType<typeof buildUser> | null) => {
  const queryClient = new QueryClient();
  if (user) {
    queryClient.setQueryData(AUTH_QUERY_KEY, user);
  }
  return queryClient;
};

/*
  Pure unit tests for the requireAuthorization function, which is used by route loaders to enforce role-based access control.
  These tests do not involve any React components or routing, and focus solely on the logic of authorization checks.
*/
describe('requireAuthorization', () => {
  it('should return the user when they have the required role', async () => {
    const adminUser = buildUser({ isAdmin: true });
    const queryClient = createQueryClientWithUser(adminUser);

    const result = await requireAuthorization(queryClient, [ROLES.ADMIN]);

    expect(result).toEqual(adminUser);
  });

  it('should perform OR-based role check (user needs only one of the required roles)', async () => {
    const regularUser = buildUser({ isAdmin: false });
    const queryClient = createQueryClientWithUser(regularUser);

    const result = await requireAuthorization(queryClient, [ROLES.ADMIN, ROLES.USER]);

    expect(result).toEqual(regularUser);
  });

  it('should throw an authorization error when user lacks the required role', async () => {
    const regularUser = buildUser({ isAdmin: false });
    const queryClient = createQueryClientWithUser(regularUser);

    await expect(
      requireAuthorization(queryClient, [ROLES.ADMIN]),
    ).rejects.toSatisfy((error: unknown) => isAuthorizationError(error));
  });

  it('should include the allowed roles in the authorization error', async () => {
    const regularUser = buildUser({ isAdmin: false });
    const queryClient = createQueryClientWithUser(regularUser);

    try {
      await requireAuthorization(queryClient, [ROLES.ADMIN]);
      expect.fail('Expected an authorization error to be thrown');
    } catch (error) {
      if (isAuthorizationError(error)) {
        expect(error.allowedRoles).toEqual(['ADMIN']);
      } else {
        expect.fail('Expected an AuthorizationError');
      }
    }
  });

  it('should throw "Not authenticated" when no user is in the cache', async () => {
    const queryClient = createQueryClientWithUser(null);

    await expect(
      requireAuthorization(queryClient, [ROLES.ADMIN]),
    ).rejects.toThrow('Not authenticated');
  });

  it('should return the user when no roles are required', async () => {
    const regularUser = buildUser({ isAdmin: false });
    const queryClient = createQueryClientWithUser(regularUser);

    const result = await requireAuthorization(queryClient);

    expect(result).toEqual(regularUser);
  });

  it('should return the user when allowedRoles is an empty array', async () => {
    const regularUser = buildUser({ isAdmin: false });
    const queryClient = createQueryClientWithUser(regularUser);

    const result = await requireAuthorization(queryClient, []);

    expect(result).toEqual(regularUser);
  });
});

describe('isAuthorizationError', () => {
  it('should return true for authorization errors', async () => {
    const regularUser = buildUser({ isAdmin: false });
    const queryClient = createQueryClientWithUser(regularUser);

    try {
      await requireAuthorization(queryClient, [ROLES.ADMIN]);
    } catch (error) {
      expect(isAuthorizationError(error)).toBe(true);
    }
  });

  it('should return false for generic errors', () => {
    expect(isAuthorizationError(new Error('some error'))).toBe(false);
  });
});