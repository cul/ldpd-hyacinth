import { queryOptions, useSuspenseQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { QueueActivity } from '@/types/api';

export const getQueueActivity = async (): Promise<{ queueActivity: QueueActivity }> => {
  const res = await api.get<{ queueActivity: QueueActivity }>('/import_jobs/queue_activity');
  return res;
};

export const getQueueActivityQueryOptions = () => {
  return queryOptions({
    queryKey: ['queue-activity'],
    queryFn: getQueueActivity,
  });
};

type UseQueueActivityOptions = {
  queryConfig?: QueryConfig<typeof getQueueActivityQueryOptions>;
};

export const useQueueActivitySuspenseQuery = ({ queryConfig }: UseQueueActivityOptions = {}) => {
  return useSuspenseQuery({
    ...getQueueActivityQueryOptions(),
    ...queryConfig,
  });
};
