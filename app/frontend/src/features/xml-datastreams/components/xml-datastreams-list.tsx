import type { ColumnDef } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { XmlDatastream } from '@/types/api';
import { columnDefs } from '../utils/xml-datastreams-list-column-defs'
import { useXmlDatastreamsSuspenseQuery } from '../api/get-xml-datastreams';

export const XmlDatastreamsList = () => {
  const xmlDatastreamsQuery = useXmlDatastreamsSuspenseQuery();
  const xmlDatastreams = xmlDatastreamsQuery.data.xmlDatastreams;

  return <TableBuilder data={xmlDatastreams} columns={columnDefs as ColumnDef<XmlDatastream>[]} />
}