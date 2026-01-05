// Where should this file live?
import React from 'react'
import { Link } from 'react-router'
import { createColumnHelper } from '@tanstack/react-table'
import { User } from '@/types/api'

const columnHelper = createColumnHelper<User>()

export const columnDefs = [
  columnHelper.accessor('uid', {
    header: 'UID',
    cell: ({ row }) => (
      <Link
        to={{ pathname: `/users/${row.original.uid}/edit` }}
        className="link-underline link-underline-opacity-0"
      >
        <span className="hover:underline">{row.original.uid}</span>
      </Link>
    )
  }),
  columnHelper.accessor((row) => `${row.firstName} ${row.lastName}`, {
    id: 'name',
    header: 'Name',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('email', {
    header: 'Email',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('isAdmin', {
    header: 'Is Admin',
    cell: (info) => info.getValue() ? 'true' : 'false',
  }),
  columnHelper.accessor('canManageAllControlledVocabularies', {
    header: 'Can Manage Vocabularies',
    cell: (info) => info.getValue() ? 'true' : 'false',
  }),
  columnHelper.accessor('accountType', {
    header: 'Account Type',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('isActive', {
    header: 'Is Active',
    cell: (info) => info.getValue() ? 'true' : 'false',
  }),
]