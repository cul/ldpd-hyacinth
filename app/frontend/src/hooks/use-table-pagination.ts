import { useCallback } from 'react';
import { useSearchParams } from 'react-router';
import type { PaginationState, Updater } from '@tanstack/react-table';
import type { Pagination } from '@/types/api';

interface TablePaginationProps {
  state: PaginationState;
  onPaginationChange: (updater: Updater<PaginationState>) => void;
  rowCount: number;
}

// Provides a hook for managing table pagination state based on URL search parameters
export const useTablePagination = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const page = Number(searchParams.get('page')) || 1;

  const getPaginationProps = useCallback(
    (pagination: Pagination): TablePaginationProps => {
      const state: PaginationState = {
        pageIndex: page - 1,
        pageSize: pagination.perPage,
      };

      const onPaginationChange = (updater: Updater<PaginationState>) => {
        const next = typeof updater === 'function' ? updater(state) : updater;
        setSearchParams((prev) => {
          prev.set('page', String(next.pageIndex + 1));
          return prev;
        });
      };

      return { state, onPaginationChange, rowCount: pagination.totalCount };
    },
    [page, setSearchParams],
  );

  return { page, getPaginationProps };
};
