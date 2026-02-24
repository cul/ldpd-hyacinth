import { describe, it, expect } from 'vitest';
import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { createColumnHelper, ColumnDef } from '@tanstack/react-table';
import TableBuilder from '@/components/ui/table-builder/table-builder';

// Test-specific types and column defs.
// Intentionally decoupled from app data to test TableBuilder as a generic component.
type Fruit = {
  name: string;
  color: string;
  calories: number;
  seasonal: boolean;
};

const columnHelper = createColumnHelper<Fruit>();

const columns = [
  columnHelper.accessor('name', {
    header: 'Name',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('color', {
    header: 'Color',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('calories', {
    header: 'Calories',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('seasonal', {
    header: 'Seasonal',
    cell: (info) => (info.getValue() ? 'Yes' : 'No'),
    enableSorting: false,
  }),
];

const fruits: Fruit[] = [
  { name: 'Banana', color: 'Yellow', calories: 95, seasonal: false },
  { name: 'Apple', color: 'Red', calories: 105, seasonal: true },
  { name: 'Cherry', color: 'Red', calories: 50, seasonal: true },
];

const renderTable = (data: Fruit[] = fruits) =>
  render(<TableBuilder data={data} columns={columns as ColumnDef<Fruit>[]} />);

// Returns text content of the Nth column across all data rows (skips header)
const getColumnValues = (columnIndex: number): string[] => {
  const rows = screen.getAllByRole('row');

  return rows.slice(1).map(
    (row) => within(row).getAllByRole('cell')[columnIndex].textContent!,
  );
};

describe('TableBuilder', () => {
  describe('rendering', () => {
    it('should render all column headers', () => {
      renderTable();

      expect(screen.getByRole('columnheader', { name: /name/i })).toBeInTheDocument();
      expect(screen.getByRole('columnheader', { name: /color/i })).toBeInTheDocument();
      expect(screen.getByRole('columnheader', { name: /calories/i })).toBeInTheDocument();
      expect(screen.getByRole('columnheader', { name: /seasonal/i })).toBeInTheDocument();
    });

    it('should render one row per data item', () => {
      renderTable();

      // 3 data rows + 1 header row
      const rows = screen.getAllByRole('row');
      expect(rows).toHaveLength(4);
    });

    it('should render cell values from the data', () => {
      renderTable();

      expect(screen.getByText('Banana')).toBeInTheDocument();
      expect(screen.getByText('Apple')).toBeInTheDocument();
      expect(screen.getByText('Cherry')).toBeInTheDocument();
    });

    it('should apply custom cell renderers', () => {
      renderTable();

      // The "seasonal" column renders booleans as Yes/No
      const seasonalValues = getColumnValues(3);

      expect(seasonalValues).toContain('Yes');
      expect(seasonalValues).toContain('No');
    });

    it('should render headers but no data rows when data is empty', () => {
      renderTable([]);

      expect(screen.getByRole('columnheader', { name: /name/i })).toBeInTheDocument();

      const rows = screen.getAllByRole('row');
      expect(rows).toHaveLength(1); // header only
    });
  });

  describe('sorting', () => {
    it('should sort ascending on first click of a sortable column', async () => {
      renderTable();

      await userEvent.click(screen.getByRole('button', { name: /name/i }));

      expect(getColumnValues(0)).toEqual(['Apple', 'Banana', 'Cherry']);
    });

    it('should sort descending on second click', async () => {
      renderTable();

      const nameHeader = screen.getByRole('button', { name: /name/i });

      await userEvent.click(nameHeader);
      await userEvent.click(nameHeader);

      expect(getColumnValues(0)).toEqual(['Cherry', 'Banana', 'Apple']);
    });

    // TanStack Table detects numeric values and defaults to descending-first, unlike text columns.
    it('should sort numeric columns descending first (TanStack auto-detects number type)', async () => {
      renderTable();

      const caloriesHeader = screen.getByRole('button', { name: /calories/i });

      await userEvent.click(caloriesHeader);
      expect(getColumnValues(2)).toEqual(['105', '95', '50']);

      await userEvent.click(caloriesHeader);
      expect(getColumnValues(2)).toEqual(['50', '95', '105']);
    });

    it('should not render a sort button for columns with sorting disabled', () => {
      renderTable();

      // "Seasonal" has enableSorting: false — should render as plain text, not a button
      const seasonalHeader = screen.getByRole('columnheader', { name: /seasonal/i });

      expect(within(seasonalHeader).queryByRole('button')).not.toBeInTheDocument();
    });

    it('should render a sort button for sortable columns', () => {
      renderTable();

      const nameHeader = screen.getByRole('columnheader', { name: /name/i });

      expect(within(nameHeader).getByRole('button')).toBeInTheDocument();
    });
  });
});

