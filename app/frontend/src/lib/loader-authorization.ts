import { QueryClient } from '@tanstack/react-query';
import { AUTH_QUERY_KEY } from './auth';
import { User } from '@/types/api';
import { ROLES, hasAnyRole } from './authorization';

type RoleTypes = keyof typeof ROLES;

export type AuthorizationErrorData = {
  type: 'AUTHORIZATION_ERROR';
  message: string;
  allowedRoles: RoleTypes[];
};

// Create an authorization error with metadata
export function createAuthorizationError(
  message: string,
  allowedRoles: RoleTypes[]
): Error & AuthorizationErrorData {
  const error = new Error(message) as Error & AuthorizationErrorData;
  error.type = 'AUTHORIZATION_ERROR';
  error.allowedRoles = allowedRoles;
  return error;
}

export function isAuthorizationError(error: unknown): error is Error & AuthorizationErrorData {
  return (
    error instanceof Error &&
    'type' in error &&
    error.type === 'AUTHORIZATION_ERROR' &&
    'allowedRoles' in error
  );
}

/**
 * Checks if the current user has the required roles before allowing loader to proceed
 * This should be called at the beginning of any loader that requires authorization
 * 
 * @param queryClient - React Query client to access cached user data
 * @param allowedRoles - Array of roles that are allowed to access this route
 * @returns The authenticated user if authorized
 * @throws Error if user lacks required permissions
 */
export async function requireAuthorization(
  queryClient: QueryClient,
  allowedRoles?: RoleTypes[]
): Promise<User> {
  // Get the current user from the query cache (should be pre-loaded by AuthLoader)
  const user = queryClient.getQueryData<User>(AUTH_QUERY_KEY);

  // If no user is found, throw an error
  // This shouldn't happen since all pages except sign-in are behind Rails auth
  if (!user) {
    throw new Error('Not authenticated');
  }

  // If no roles are required, user is authorized
  if (!allowedRoles || allowedRoles.length === 0) {
    return user;
  }

  // Check if user has any of the required roles
  if (!hasAnyRole(user, allowedRoles)) {
    // Throw an authorization error that can be caught by error boundaries
    throw createAuthorizationError(
      `Access denied.  User must have at least one of the following roles: ${allowedRoles.join(', ')}`,
      allowedRoles
    );
  }

  return user;
}
