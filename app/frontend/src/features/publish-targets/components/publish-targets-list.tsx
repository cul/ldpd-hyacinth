import type { ColumnDef } from '@tanstack/react-table';
import { Spinner } from 'react-bootstrap';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { PublishTarget } from '@/types/api';
import { columnDefs } from '../utils/publish-targets-list-column-defs'
import { usePublishTargets } from '../api/get-publish-targets';


const PublishTargetsList = () => {
  const publishTargetsQuery = usePublishTargets();

  if (publishTargetsQuery.isLoading) {
    return <Spinner />;
  }

  const publishTargets = publishTargetsQuery.data?.publishTargets;
  console.log('publishTargets', publishTargets);
  if (!publishTargets) return null;

  return (
    <TableBuilder data={publishTargets} columns={columnDefs as ColumnDef<PublishTarget>[]} />
  );

}

export default PublishTargetsList;