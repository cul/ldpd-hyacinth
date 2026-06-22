import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';

export const createimportJob = ({
  data,
}: {
  data: { file: File; priority: string };
}): Promise<{ importJob: any }> => {
  const formData = new FormData();
  formData.append('import_file', data.file);
  formData.append('import_job[priority]', data.priority);

  return api.post(`/import_jobs`, formData);
};

type UseCreateimportJobOptions = {
  mutationConfig?: MutationConfig<typeof createimportJob>;
};

export const useCreateImportJob = ({ mutationConfig }: UseCreateimportJobOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  return useMutation({
    onSuccess: (...args) => {
      queryClient.invalidateQueries({
        queryKey: ['import-jobs'], // TODO: replace with const
      });
      onSuccess?.(...args);
    },
    ...restConfig,
    mutationFn: createimportJob,
  });
};
