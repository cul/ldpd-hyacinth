import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { QueryClient } from '@tanstack/react-query';
import { getXmlDatastreamsQueryOptions } from '@/features/xml-datastreams/api/get-xml-datastreams';
import { XmlDatastreamsList } from '@/features/xml-datastreams/components/xml-datastreams-list';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const query = getXmlDatastreamsQueryOptions();
  return await queryClient.ensureQueryData(query);
};

const XmlDatastreamsIndexRoute = () => {
  return <XmlDatastreamsList />
};

export default XmlDatastreamsIndexRoute;