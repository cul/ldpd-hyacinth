import { QueryClient } from '@tanstack/react-query';
import { useParams, LoaderFunctionArgs } from 'react-router';
import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { XmlDatastreamForm } from '@/features/xml-datastreams/components/xml-datastream-form';
import { getXmlDatastreamQueryOptions, useXmlDatastreamSuspenseQuery } from '@/features/xml-datastreams/api/get-xml-datastream';

export const clientLoader = (queryClient: QueryClient) => async ({ params }: LoaderFunctionArgs) => {
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const xmlDatastreamStringKey = params.xmlDatastreamStringKey as string;
  const xmlDatastreamQuery = getXmlDatastreamQueryOptions(xmlDatastreamStringKey);
  return await queryClient.ensureQueryData(xmlDatastreamQuery);
};

const XmlDatastreamsEditRoute = () => {
  const params = useParams();
  const xmlDatastreamStringKey = params.xmlDatastreamStringKey as string;

  const xmlDatastreamQuery = useXmlDatastreamSuspenseQuery({ xmlDatastreamStringKey });
  const xmlDatastream = xmlDatastreamQuery.data.xmlDatastream;

  return <XmlDatastreamForm xmlDatastream={xmlDatastream} />
};

export default XmlDatastreamsEditRoute;