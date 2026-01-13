import React from 'react'
import { createColumnHelper } from '@tanstack/react-table'
import { Form } from 'react-bootstrap';
import { ProjectPermission } from '@/types/api'

const columnHelper = createColumnHelper<ProjectPermission>()

const cellAsEditableCheckbox = (info: any) => {
  const value = info.getValue()
  const updateData = info.table.options.meta?.updateData

  return (
    <Form.Check
      type="checkbox"
      checked={value}
      onChange={(e) => {
        updateData?.(info.row.index, info.column.id, e.target.checked)
      }}
    />
  )
}

export const columnDefs = [
  columnHelper.accessor('projectDisplayLabel', {
    header: 'Project',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('canRead', {
    header: 'Can Read',
    // Read permission is always true and not editable
    cell: (info) => (
      <Form.Check
        type="checkbox"
        checked={info.getValue()}
        disabled
      />
    ),
  }),
  columnHelper.accessor('canUpdate', {
    header: 'Can Update',
    cell: (info) => cellAsEditableCheckbox(info),
  }),
  columnHelper.accessor('canCreate', {
    header: 'Can Create',
    cell: (info) => cellAsEditableCheckbox(info),
  }),
  columnHelper.accessor('canDelete', {
    header: 'Can Delete',
    cell: (info) => cellAsEditableCheckbox(info),
  }),
  columnHelper.accessor('canPublish', {
    header: 'Can Publish',
    cell: (info) => cellAsEditableCheckbox(info),
  }),
  columnHelper.accessor('isProjectAdmin', {
    header: 'Is Project Admin',
    cell: (info) => cellAsEditableCheckbox(info),
  }),
];