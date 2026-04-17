import { QueryClient } from '@tanstack/react-query';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { XmlDatastreamForm } from '@/features/xml-datastreams/components/xml-datastream-form';

export const clientLoader = (queryClient: QueryClient) => async () => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);
};

const XmlDatastreamsNewRoute = () => {
  return <XmlDatastreamForm />
};

export default XmlDatastreamsNewRoute;