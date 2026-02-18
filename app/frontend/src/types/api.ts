export interface User {
  uid: string;
  firstName: string;
  lastName: string;
  email: string;
  isAdmin: boolean;
  isActive: boolean;
  canManageAllControlledVocabularies: boolean;
  adminForAtLeastOneProject: boolean;
  canEditAtLeastOneControlledVocabulary: boolean;
  accountType: string;
  apiKeyDigest?: string | null;
}

export interface Project {
  id: number;
  stringKey: string;
  displayLabel: string;
  pid: string;
}

export interface ProjectPermission {
  projectId: number;
  projectDisplayLabel: string;
  projectStringKey: string;
  canRead: boolean;
  canUpdate: boolean;
  canCreate: boolean;
  canDelete: boolean;
  canPublish: boolean;
  isProjectAdmin: boolean;
}