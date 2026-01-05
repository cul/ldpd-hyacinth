export interface User {
  uid: string;
  firstName: string;
  lastName: string;
  email: string;
  isAdmin: boolean;
  isActive: boolean;
  canManageAllControlledVocabularies: boolean;
  accountType: string;
  signInCount: number;
  currentSignInAt: string;
  lastSignInAt: string;
  currentSignInIp: string;
  lastSignInIp: string;
  createdAt: string;
  updatedAt: string;
}