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

export interface ProjectPermission {
  projectDisplayLabel: string;
  projectPid: string;
  projectStringKey: string;
  canRead: boolean;
  canUpdate: boolean;
  canCreate: boolean;
  canPublish: boolean;
  isProjectAdmin: boolean;
}