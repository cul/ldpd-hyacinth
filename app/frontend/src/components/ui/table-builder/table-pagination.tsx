import { Table } from '@tanstack/react-table';
import { Pagination } from 'react-bootstrap';

interface TablePaginationProps<T> {
  table: Table<T>;
}

function TablePagination<T>({ table }: TablePaginationProps<T>) {
  const { pageIndex, pageSize } = table.getState().pagination;

  const totalRows = table.options.rowCount ?? 0;

  const pageCount = Math.max(table.getPageCount(), 1);
  const startRow = totalRows === 0 ? 0 : pageIndex * pageSize + 1;
  const endRow = Math.min((pageIndex + 1) * pageSize, totalRows);

  return (
    <Pagination className="mt-2 align-items-center">
      <Pagination.First onClick={() => table.firstPage()} disabled={!table.getCanPreviousPage()} />
      <Pagination.Prev
        onClick={() => table.previousPage()}
        disabled={!table.getCanPreviousPage()}
      />
      <Pagination.Item active>
        {pageIndex + 1} of {pageCount}
      </Pagination.Item>
      <Pagination.Next onClick={() => table.nextPage()} disabled={!table.getCanNextPage()} />
      <Pagination.Last onClick={() => table.lastPage()} disabled={!table.getCanNextPage()} />
      <div className="d-flex align-items-center p-2">
        Showing {startRow}-{endRow} of {totalRows}
      </div>
    </Pagination>
  );
}

export default TablePagination;
