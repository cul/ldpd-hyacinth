import { useEffect, useState, useMemo } from 'react';
import { arePermissionArraysEqual } from '../utils/permissions';
import { ProjectPermission } from '@/types/api';
import { useUserProjects } from '../api/get-user-projects';
import { useUpdateUserProjectPermissions } from '../api/update-user-projects';

interface UseProjectPermissionsFormProps {
  userUid: string;
}

// TODO: Update functions to use useCallback where appropriate
export const useProjectPermissionsForm = ({ userUid }: UseProjectPermissionsFormProps) => {
  const userPermissionsQuery = useUserProjects({ userUid });
  const [data, setData] = useState<ProjectPermission[]>([]);
  const [selectedUserUid, setSelectedUserUid] = useState<string>('');
  const [originalData, setOriginalData] = useState<ProjectPermission[]>([]); // Keep track of original data to compare for changes

  // Fetch selected user's permissions only when a user is selected
  const selectedUserPermissionsQuery = useUserProjects({
    userUid: selectedUserUid,
    queryConfig: {
      enabled: !!selectedUserUid,
    },
  });

  const updatePermissionsMutation = useUpdateUserProjectPermissions({
    mutationConfig: {
      onSuccess: () => {
        setOriginalData(data);
      },
    },
  });

  const updatePermission = (rowIndex: number, columnId: string, value: boolean) => {
    setData((old) =>
      old.map((row, index) => {
        if (index === rowIndex) {
          return {
            ...row,
            [columnId]: value,
          };
        }
        return row;
      })
    );
  };

  const addPermission = (newPermission: ProjectPermission) => {
    setData((old) => [newPermission, ...old]);
  };

  const removePermission = (rowIndex: number) => {
    setData((old) => old.filter((_, index) => index !== rowIndex));
  };

  const mergePermissions = () => {
    if (!selectedUserUid || !selectedUserPermissionsQuery.data) return;

    const selectedPermissions = selectedUserPermissionsQuery.data;

    // Merge permissions: add new projects, preserve existing ones
    const mergedData = [...data];
    selectedPermissions.forEach(permission => {
      const existingIndex = mergedData.findIndex(p => p.projectId === permission.projectId);
      if (existingIndex === -1) {
        mergedData.push(permission);
      }
    });

    setData(mergedData);
    setSelectedUserUid('');
  };

  useEffect(() => {
    if (userPermissionsQuery.data) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setData(userPermissionsQuery.data);
      setOriginalData(userPermissionsQuery.data);
    }
  }, [userPermissionsQuery.data]);

  const hasChanges = useMemo(() => {
    return !arePermissionArraysEqual(data, originalData);
  }, [data, originalData]);

  const handleSave = () => {
    updatePermissionsMutation.mutate({
      userUid,
      projectPermissions: data,
    });
  };

  return {
    data,
    hasChanges,
    isLoading: userPermissionsQuery.isLoading,
    isError: userPermissionsQuery.isError,
    error: userPermissionsQuery.error,
    addPermission,
    updatePermission,
    removePermission,
    handleSave,
    mutation: updatePermissionsMutation,
    // Copy permissions from another user
    selectedUserUid,
    setSelectedUserUid,
    mergePermissions,
  };
}