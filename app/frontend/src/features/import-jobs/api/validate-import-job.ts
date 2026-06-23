import { useMutation } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';

export const validateImportJob = ({
  data,
}: {
  data: { file: File; priority: string };
}): Promise<{ importJob: any }> => {
  const formData = new FormData();
  formData.append('import_file', data.file);
  formData.append('import_job[priority]', data.priority);

  return api.post(`/import_jobs/validate`, formData);
};

type UseValidateImportJobOptions = {
  mutationConfig?: MutationConfig<typeof validateImportJob>;
};

export const useValidateImportJob = ({ mutationConfig }: UseValidateImportJobOptions = {}) => {
  return useMutation({
    mutationFn: validateImportJob,
    ...mutationConfig,
  });
};
