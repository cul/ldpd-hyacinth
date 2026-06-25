import '@tanstack/react-table';

// Extends the TableMeta interface to include an optional onDeleteRow function
// https://tanstack.com/table/v8/docs/api/core/table#meta
declare module '@tanstack/react-table' {
  interface TableMeta<TData> {
    onDeleteRow?: (row: TData) => void;
  }
}
