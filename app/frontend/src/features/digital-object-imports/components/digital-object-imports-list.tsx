import { useSearchParams } from 'react-router';
import type { ColumnDef, PaginationState, Updater } from '@tanstack/react-table';
import TableBuilder from '@/components/ui/table-builder/table-builder';
import { columnDefs } from '../utils/digital-object-imports-column-defs';
import { useDigitalObjectImportsSuspenseQuery } from '../api/get-digital-object-imports';
import { DigitalObjectImportSummary } from '@/types/api';
import { StatusFilter } from './status-filter';

interface DigitalObjectImportsListProps {
  importJobId: string;
}

const options = ['pending', 'success', 'failure'];

export const DigitalObjectImportsList = ({ importJobId }: DigitalObjectImportsListProps) => {
  const [searchParams, setSearchParams] = useSearchParams();
  const page = Number(searchParams.get('page')) || 1;
  const status = searchParams.get('status') ?? undefined;

  const query = useDigitalObjectImportsSuspenseQuery({ importJobId, page, status });
  const { digitalObjectImports, pagination } = query.data;

  // same logic as in import-jobs-list.tsx, could this be refactored/extracted?
  const paginationState: PaginationState = {
    pageIndex: page - 1,
    pageSize: pagination.perPage,
  };

  // same logic as in import-jobs-list.tsx, could this be refactored/extracted?
  const handlePaginationChange = (updater: Updater<PaginationState>) => {
    const next = typeof updater === 'function' ? updater(paginationState) : updater;
    setSearchParams((prev) => {
      prev.set('page', String(next.pageIndex + 1));
      return prev;
    });
  };

  const handleStatusChange = (newStatus: string | null) => {
    setSearchParams((prev) => {
      if (newStatus) {
        prev.set('status', newStatus);
      } else {
        prev.delete('status');
      }
      prev.delete('page'); // Resets to page 1 whenever the filter changes
      return prev;
    });
  };

  return (
    <>
      {/* TODO: This component shares the navigation that import-jobs-list.tsx uses, change it so the back button leads to the import job details */}
      <StatusFilter active={status ?? null} options={options} onChange={handleStatusChange} />

      <TableBuilder
        data={digitalObjectImports}
        columns={columnDefs as ColumnDef<DigitalObjectImportSummary>[]}
        pagination={{
          state: paginationState,
          onPaginationChange: handlePaginationChange,
          rowCount: pagination.totalCount,
        }}
      />
    </>
  );
};
