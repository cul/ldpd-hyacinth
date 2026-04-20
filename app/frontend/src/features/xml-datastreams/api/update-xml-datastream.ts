import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { XmlDatastream } from '@/types/api';
import { getXmlDatastreamsQueryOptions } from './get-xml-datastreams';

export const updateXmlDatastream = ({
  xmlDatastreamStringKey,
  data,
}: {
  xmlDatastreamStringKey: string;
  data: Partial<XmlDatastream>;
}): Promise<{ xmlDatastream: XmlDatastream }> => {
  return api.patch(`/xml_datastreams/${xmlDatastreamStringKey}`, { xmlDatastream: data });
};

type UseUpdateXmlDatastreamOptions = {
  mutationConfig?: MutationConfig<typeof updateXmlDatastream>;
};

export const useUpdateXmlDatastream = ({
  mutationConfig,
}: UseUpdateXmlDatastreamOptions = {}) => {
  const queryClient = useQueryClient();

  const { onSuccess, ...restConfig } = mutationConfig || {};

  return useMutation({
    onSuccess: (...args) => {
      queryClient.invalidateQueries({
        queryKey: getXmlDatastreamsQueryOptions().queryKey,
      });

      onSuccess?.(...args);
    },
    ...restConfig,
    mutationFn: updateXmlDatastream,
  });
};
