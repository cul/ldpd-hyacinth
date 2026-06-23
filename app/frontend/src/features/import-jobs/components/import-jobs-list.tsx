import type { ColumnDef } from '@tanstack/react-table';

import TableBuilder from '@/components/ui/table-builder/table-builder';
import { columnDefs } from '../utils/import-jobs-list-column-defs';
import { useImportJobsSuspenseQuery } from '../api/get-import-jobs';
import { ImportJob } from '@/types/api';

const ImportJobsList = () => {
  const importJobsQuery = useImportJobsSuspenseQuery();
  const importJobs = importJobsQuery.data.importJobs;

  return <TableBuilder data={importJobs} columns={columnDefs as ColumnDef<ImportJob>[]} />;
};

export default ImportJobsList;
