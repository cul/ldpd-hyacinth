import { queryOptions, useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { PublishTarget } from '@/types/api';

export const getPublishTargets = async (): Promise<{ publishTargets: PublishTarget[] }>=> {
  const res = await api.get<{ publishTargets: PublishTarget[] }>('/publish_targets');
  return res;
};

export const getPublishTargetsQueryOptions = () => {
  return queryOptions({
    queryKey: ['publishTargets'],
    queryFn: getPublishTargets,
  });
};

type UsePublishTargetsOptions = {
  queryConfig?: QueryConfig<typeof getPublishTargetsQueryOptions>;
};

export const usePublishTargets = ({ queryConfig }: UsePublishTargetsOptions = {}) => {
  return useQuery({
    ...getPublishTargetsQueryOptions(),
    ...queryConfig,
  });
};
