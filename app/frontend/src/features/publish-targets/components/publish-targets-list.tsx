import type { ColumnDef } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { PublishTarget } from '@/types/api';
import { columnDefs } from '../utils/publish-targets-list-column-defs'
import { usePublishTargetsSuspenseQuery } from '../api/get-publish-targets';

const PublishTargetsList = () => {
  const publishTargetsQuery = usePublishTargetsSuspenseQuery();
  const publishTargets = publishTargetsQuery.data.publishTargets;

  return (
    <TableBuilder data={publishTargets} columns={columnDefs as ColumnDef<PublishTarget>[]} />
  );
}

export default PublishTargetsList;