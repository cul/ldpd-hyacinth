// Where should this file live?
import { createColumnHelper, ColumnDef } from '@tanstack/react-table'
import { User } from '../../../types/api'

const columnHelper = createColumnHelper<User>()

export const columnDefs = [
  columnHelper.accessor('uid', {
    header: 'UID',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor((row) => `${row.first_name} ${row.last_name}`, {
    id: 'name',
    header: 'Name',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('email', {
    header: 'Email',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('is_admin', {
    header: 'Is Admin',
    cell: (info) => info.getValue() ? 'true' : 'false',
  }),
  columnHelper.accessor('can_manage_all_controlled_vocabularies', {
    header: 'Can Manage Vocabularies',
    cell: (info) => info.getValue() ? 'true' : 'false',
  }),
  columnHelper.accessor('account_type', {
    header: 'Account Type',
    cell: (info) => info.getValue() === 1 ? 'service' : 'standard',
  }),
  columnHelper.accessor('is_active', {
    header: 'Is Active',
    cell: (info) => info.getValue() ? 'true' : 'false',
  }),
]