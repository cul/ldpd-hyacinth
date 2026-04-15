import { queryOptions, useSuspenseQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { XmlDatastream } from '@/types/api';

export const getXmlDatastreams = async (): Promise<{ xmlDatastreams: XmlDatastream[] }> => {
  const res = await api.get<{ xmlDatastreams: XmlDatastream[] }>('/xml_datastreams');
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
