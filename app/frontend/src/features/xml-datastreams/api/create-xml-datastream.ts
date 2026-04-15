import { useMutation, useQueryClient } from '@tanstack/react-query';

import { api } from '@/lib/api-client';
import { MutationConfig } from '@/lib/react-query';
import { XmlDatastream } from '@/types/api';
import { getXmlDatastreamsQueryOptions } from './get-xml-datastreams';

export const createXmlDatastream = ({ data }: { data: Partial<XmlDatastream> }): Promise<{ xmlDatastream: XmlDatastream }> => {
  return api.post(`/xml_datastreams`, { xmlDatastream: data });
};

type UseCreateXmlDatastreamOptions = {
  mutationConfig?: MutationConfig<typeof createXmlDatastream>;
};

export const useCreateXmlDatastream = ({
  mutationConfig,
}: UseCreateXmlDatastreamOptions = {}) => {
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
    mutationFn: createXmlDatastream,
  });
};
