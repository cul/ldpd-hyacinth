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
  project_pid: string;
  project_string_key: string;
  can_read: boolean;
  can_update: boolean;
  can_create: boolean;
  can_publish: boolean;
  is_project_admin: boolean;
}