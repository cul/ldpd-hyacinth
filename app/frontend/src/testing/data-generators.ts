import type { ProjectPermission, User } from '@/types/api';

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
const PROJECT_PERMISSION_DEFAULTS: ProjectPermission = {
  projectId: 1,
  projectDisplayLabel: 'Test Project Alpha',
  projectStringKey: 'test-project-alpha',
  canRead: true,
  canUpdate: false,
  canCreate: false,
  canDelete: false,
  canPublish: false,
  isProjectAdmin: false,
};

export const buildProjectPermission = (overrides?: Partial<ProjectPermission>): ProjectPermission => {
  return {
    ...PROJECT_PERMISSION_DEFAULTS,
    ...overrides,
  };
}