import { queryOptions, useSuspenseQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { QueryConfig } from '@/lib/react-query';
import { XmlDatastream } from '@/types/api';

export const getXmlDatastream = async (xmlDatastreamStringKey: string): Promise<{ xmlDatastream: XmlDatastream }> => {
  const res = await api.get<{ xmlDatastream: XmlDatastream }>(`/xml_datastreams/${xmlDatastreamStringKey}`);
  return res;
};

export const getXmlDatastreamQueryOptions = (xmlDatastreamStringKey: string) => {
  return queryOptions({
    queryKey: ['xml-datastreams', xmlDatastreamStringKey],
    queryFn: () => getXmlDatastream(xmlDatastreamStringKey),
  });
};

type UseXmlDatastreamOptions = {
  xmlDatastreamStringKey: string;
  queryConfig?: QueryConfig<typeof getXmlDatastreamQueryOptions>;
};

export const useXmlDatastreamSuspenseQuery = ({ xmlDatastreamStringKey, queryConfig }: UseXmlDatastreamOptions) => {
  return useSuspenseQuery({
    ...getXmlDatastreamQueryOptions(xmlDatastreamStringKey!),
    ...queryConfig,
  });
};
