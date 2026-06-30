import { Link, useSearchParams } from 'react-router';
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
  const { digitalObjectImports, pagination, importJobName } = query.data;

  // TODO: This is the same logic as in import-jobs-list.tsx; might work well as a custom hook
  const paginationState: PaginationState = {
    pageIndex: page - 1,
    pageSize: pagination.perPage,
  };

  // TODO: This is the same logic as in import-jobs-list.tsx; might work well as a custom hook
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
      <h2 className="mb-4">
        Digital Object Imports for <Link to={`/import-jobs/${importJobId}`}>{importJobName}</Link>
      </h2>

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
