import React from 'react';
import { useCurrentUser } from './auth';
import { User } from '@/types/api';

export enum ROLES {
  ADMIN = 'ADMIN',
  USER = 'USER',
}

type RoleTypes = keyof typeof ROLES;

// Helper function to get user roles
export function getUserRoles(user: User | null | undefined): RoleTypes[] {
  if (!user) return [];

  const roles: RoleTypes[] = ['USER'];
  if (user.isAdmin) {
    roles.push('ADMIN');
  }

  return roles;
}

// Helper function to check if user has any of the specified roles
export function hasRole(
  user: User | null | undefined,
  allowedRoles: RoleTypes[]
): boolean {
  if (!user) return false;

  const userRoles = getUserRoles(user);
  return allowedRoles.some(role => userRoles.includes(role));
}

// Hook for authorization checks
export function useAuthorization() {
  const { data: user } = useCurrentUser();

  return {
    checkAccess: React.useCallback(
      (allowedRoles?: RoleTypes[]) => {
        if (!allowedRoles) return true;
        return hasRole(user, allowedRoles);
      },
      [user]
    ),
    user,
    roles: getUserRoles(user),
    isAdmin: user?.isAdmin ?? false,
  };
}

type AuthorizationProps = {
  children: React.ReactNode;
  allowedRoles?: RoleTypes[];
  forbiddenFallback?: React.ReactNode;
};

// Component for conditional rendering based on authorization
// If used for hiding content, don't provide a forbiddenFallback
export const Authorization = ({
  children,
  allowedRoles,
  forbiddenFallback = null,
}: AuthorizationProps) => {
  const { checkAccess } = useAuthorization();

  const canAccess = checkAccess(allowedRoles);
  console.log('Authorization: canAccess=', canAccess, 'for roles=', allowedRoles);

  return <>{canAccess ? children : forbiddenFallback}</>;
};
