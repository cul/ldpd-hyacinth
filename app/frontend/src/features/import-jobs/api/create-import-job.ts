import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { ImportJobSummary } from '@/types/api';

export type CreateImportJobInput = {
  data: {
    file: File;
    priority: string;
    restoreArchivedS3ObjectsForNewAssets: boolean;
  };
};

export const createImportJob = ({
  data,
}: CreateImportJobInput): Promise<{ importJob: ImportJobSummary }> => {
  const formData = new FormData();
  formData.append('import_file', data.file);
  formData.append('priority', data.priority);
  formData.append(
    'restore_archived_s3_objects_for_new_assets',
    String(data.restoreArchivedS3ObjectsForNewAssets),
  );

  return api.post('/import_jobs', formData);
};

type UseCreateImportJobOptions = {
  mutationConfig?: MutationConfig<typeof createImportJob>;
};

export const useCreateImportJob = ({ mutationConfig }: UseCreateImportJobOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  return useMutation({
    onSuccess: (...args) => {
      queryClient.invalidateQueries({
        queryKey: ['import-jobs'],
      });
      onSuccess?.(...args);
    },
    ...restConfig,
    mutationFn: createImportJob,
  });
};
