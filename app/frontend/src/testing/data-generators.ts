import type { User } from '@/types/api';

// Generate user
const USER_DEFAULTS: User = {
  uid: 'testadmin',
  firstName: 'Test',
  lastName: 'User',
  email: 'test.user@example.com',
  isAdmin: true,
  isActive: true,
  canManageAllControlledVocabularies: true,
  adminForAtLeastOneProject: true,
  canEditAtLeastOneControlledVocabulary: true,
  accountType: "standard",
  apiKeyDigest: null,
};

export const buildUser = (overrides?: Partial<User>): User => {
  return { 
    ...USER_DEFAULTS,
    ...overrides 
  };
};


// Generate project


// Generate project permission