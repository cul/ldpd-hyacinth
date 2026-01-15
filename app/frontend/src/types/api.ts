export interface User {
  uid: string;
  firstName: string;
  lastName: string;
  email: string;
  isAdmin: boolean;
  isActive: boolean;
  canManageAllControlledVocabularies: boolean;
  accountType: string;
  apiKeyDigest?: string | null;
  signInCount: number;
  currentSignInAt: string;
  lastSignInAt: string;
  currentSignInIp: string;
  lastSignInIp: string;
  createdAt: string;
  updatedAt: string;
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