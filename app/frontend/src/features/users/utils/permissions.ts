import { ProjectPermission } from '@/types/api';

const arePermissionsEqual = (
  a: ProjectPermission,
  b: ProjectPermission
): boolean => {
  return (
    a.projectId === b.projectId &&
    a.canRead === b.canRead &&
    a.canCreate === b.canCreate &&
    a.canUpdate === b.canUpdate &&
    a.canDelete === b.canDelete &&
    a.canPublish === b.canPublish &&
    a.isProjectAdmin === b.isProjectAdmin
  );
};

// Compares two arrays of ProjectPermission objects for equality
export const arePermissionArraysEqual = (
  current: ProjectPermission[],
  original: ProjectPermission[]
): boolean => {
  if (current.length !== original.length) return false;

  const sortedCurrent = [...current].sort((a, b) => a.projectId - b.projectId);
  const sortedOriginal = [...original].sort((a, b) => a.projectId - b.projectId);

  return sortedCurrent.every((current, idx) =>
    arePermissionsEqual(current, sortedOriginal[idx])
  );
};