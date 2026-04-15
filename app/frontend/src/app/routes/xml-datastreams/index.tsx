import { requireAuthorization } from '@/lib/loader-authorization';
import { ROLES } from '@/lib/authorization';
import { QueryClient } from '@tanstack/react-query';
import { getXmlDatastreamsQueryOptions, useXmlDatastreamsSuspenseQuery } from '@/features/xml-datastreams/api/get-xml-datastreams';
import type { ColumnDef } from '@tanstack/react-table';
import { columnDefs } from '../../../features/xml-datastreams/utils/xml-datastreams-list-column-defs'
import { XmlDatastream } from '@/types/api'

import TableBuilder from '@/components/ui/table-builder/table-builder';

export const clientLoader = (queryClient: QueryClient) => async () => {
  console.log('Loading XML Datastreams');
  await requireAuthorization(queryClient, [ROLES.ADMIN]);

  const query = getXmlDatastreamsQueryOptions();
  return await queryClient.ensureQueryData(query);
};

const XmlDatastreamsIndexRoute = () => {
  const xmlDatastreamsQuery = useXmlDatastreamsSuspenseQuery();
  const xmlDatastreams = xmlDatastreamsQuery.data.xmlDatastreams;

  console.log(xmlDatastreams);

  return (
    <TableBuilder data={xmlDatastreams} columns={columnDefs as ColumnDef<XmlDatastream>[]} />
  );
};

export default XmlDatastreamsIndexRoute;