import type { User } from '@/types/api';

// Generate user
const generateUser = (): User => {
  return {
    uid: 'testadmin',
    firstName: 'Test',
    lastName: 'User',
    email: 'test.user@example.com',
    isAdmin: true,
    isActive: true,
    canManageAllControlledVocabularies: true,
    adminForAtLeastOneProject: true,
    canEditAtLeastOneControlledVocabulary: true,
    accountType: '"standard"',
    apiKeyDigest: null,
  };
};

export const createUser = (overrides?: Partial<User>): User => {
  return { ...generateUser(), ...overrides };
};


// Generate project


// Generate project permission