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

export interface PublishTarget {
  stringKey: string;
  displayLabel: string;
  publishUrl: string;
  apiKey: string;
  projects: Project[];
}

export interface XmlDatastream {
  stringKey: string;
  displayLabel: string;
  xmlTranslation: string;
}

export interface ImportJobSummary {
  id: number;
  name: string;
  priority: string;
  status: string;
  createdAt: string;
  complete: boolean;
  user: {
    uid: string;
    email: string;
    fullName: string;
  };
}

export interface ImportJob extends ImportJobSummary {
  pathToCsvFile: string;
  restoreArchivedS3ObjectsForNewAssets: boolean;
  pendingCount: number;
  successCount: number;
  failureCount: number;
  updatedAt: string;
}

export interface QueueActivity {
  low: number;
  medium: number;
  high: number;
}

export interface DigitalObjectImportSummary {
  id: number;
  importJobId: number;
  status: string;
  csvRowNumber: number;
  createdAt: string;
  updatedAt: string;
}

export interface DigitalObjectImport extends DigitalObjectImportSummary {
  importJobName: string;
  digitalObjectData: string;
  digitalObjectErrors: string[];
  prerequisiteCsvRowNumbers: number[];
}

/* 
Payload types
*/

export interface PublishTargetPayload {
  stringKey: string;
  displayLabel: string;
  publishUrl: string;
  apiKey: string;
  projectIds: number[];
}
