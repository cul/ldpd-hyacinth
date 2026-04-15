import { queryOptions, useSuspenseQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';

export const getXmlDatastreams = async (): Promise<{ xmlDatastreams: unknown[] }>=> {
  const res = await api.get<{ xmlDatastreams: unknown[] }>('/xml_datastreams');
  return res;
};

export const getXmlDatastreamsQueryOptions = () => {
  return queryOptions({
    queryKey: ['xml-datastreams'],
    queryFn: getXmlDatastreams,
  });
};

type UseXmlDatastreamsOptions = {
  queryConfig?: QueryConfig<typeof getXmlDatastreamsQueryOptions>;
};

export const useXmlDatastreamsSuspenseQuery = ({ queryConfig }: UseXmlDatastreamsOptions = {}) => {
  return useSuspenseQuery({
    ...getXmlDatastreamsQueryOptions(),
    ...queryConfig,
  });
};
