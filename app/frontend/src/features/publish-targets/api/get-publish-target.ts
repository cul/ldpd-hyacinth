import { queryOptions, useSuspenseQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { PublishTarget } from '@/types/api';

export const getPublishTarget = async (publishTargetStringKey: string): Promise<{ publishTarget: PublishTarget }> => {
  const res = await api.get<{ publishTarget: PublishTarget }>(`/publish_targets/${publishTargetStringKey}`);
  return res;
};

export const getPublishTargetQueryOptions = (publishTargetStringKey: string) => {
  return queryOptions({
    queryKey: ['publish-targets', publishTargetStringKey],
    queryFn: () => getPublishTarget(publishTargetStringKey),
  });
};

type UsePublishTargetOptions = {
  publishTargetStringKey: string;
  queryConfig?: QueryConfig<typeof getPublishTargetQueryOptions>;
};

export const usePublishTargetSuspenseQuery = ({ publishTargetStringKey, queryConfig }: UsePublishTargetOptions) => {
  return useSuspenseQuery({
    ...getPublishTargetQueryOptions(publishTargetStringKey!),
    ...queryConfig,
  });
};
