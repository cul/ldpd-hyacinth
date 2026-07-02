import { Link, useSearchParams } from 'react-router';
import type { ColumnDef } from '@tanstack/react-table';
import TableBuilder from '@/components/ui/table-builder/table-builder';
import { columnDefs } from '../utils/digital-object-imports-column-defs';
import { useDigitalObjectImportsSuspenseQuery } from '../api/get-digital-object-imports';
import { DigitalObjectImportSummary } from '@/types/api';
import { StatusFilter } from './status-filter';
import { useTablePagination } from '@/hooks/use-table-pagination';

interface DigitalObjectImportsListProps {
  importJobId: string;
}

const options = ['pending', 'success', 'failure'];

export const DigitalObjectImportsList = ({ importJobId }: DigitalObjectImportsListProps) => {
  const [searchParams, setSearchParams] = useSearchParams();
  const status = searchParams.get('status') ?? undefined;
  const { page, getPaginationProps } = useTablePagination();

  const query = useDigitalObjectImportsSuspenseQuery({ importJobId, page, status });
  const { digitalObjectImports, pagination, importJobName } = query.data;

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
    <div>
      <div className="mb-4">
        <div className="text-secondary small text-uppercase fw-semibold mb-1">
          Digital object imports
        </div>
        <h2 className="mb-0">
          <Link
            to={`/import-jobs/${importJobId}`}
            className="link-underline link-underline-opacity-0 link-underline-opacity-75-hover"
          >
            {importJobName}
          </Link>
        </h2>
      </div>

      <StatusFilter active={status ?? null} options={options} onChange={handleStatusChange} />

      <TableBuilder
        data={digitalObjectImports}
        columns={columnDefs as ColumnDef<DigitalObjectImportSummary>[]}
        size="sm"
        pagination={getPaginationProps(pagination)}
      />
    </div>
  );
};
