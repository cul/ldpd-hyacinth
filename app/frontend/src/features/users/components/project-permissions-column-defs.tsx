import React from 'react'
import { createColumnHelper } from '@tanstack/react-table'
import { Form, Button } from 'react-bootstrap';
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

const cellAsReadOnlyCheckbox = (info: any) => {
  const value = info.getValue()

  return (
    <Form.Check
      type="checkbox"
      checked={value}
      disabled
    />
  )
}

// Column definitions for editable user project permissions table
export const editableColumnDefs = [
  columnHelper.accessor('projectDisplayLabel', {
    header: 'Project',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('canRead', {
    header: 'Read',
    // Read permission is always true and not editable
    cell: (info) => cellAsReadOnlyCheckbox(info),
    enableSorting: false,
  }),
  columnHelper.accessor('canUpdate', {
    header: 'Update',
    cell: (info) => cellAsEditableCheckbox(info),
    enableSorting: false,
  }),
  columnHelper.accessor('canCreate', {
    header: 'Create',
    cell: (info) => cellAsEditableCheckbox(info),
    enableSorting: false,
  }),
  columnHelper.accessor('canDelete', {
    header: 'Delete',
    cell: (info) => cellAsEditableCheckbox(info),
    enableSorting: false,
  }),
  columnHelper.accessor('canPublish', {
    header: 'Publish',
    cell: (info) => cellAsEditableCheckbox(info),
    enableSorting: false,
  }),
  columnHelper.accessor('isProjectAdmin', {
    header: 'Project Admin',
    cell: (info) => cellAsEditableCheckbox(info),
    enableSorting: false,
  }),
  columnHelper.display({
    id: 'actions',
    header: 'Actions',
    cell: props => (
      <Button
        variant="outline-secondary"
        size="sm"
        onClick={() => props.table.options.meta?.removeRow(props.row.index)}
      >
        Delete
      </Button>
    ),
    enableSorting: false,
  }),
];

// Column definitions for read-only user project permissions table (rendered in settings)
export const readOnlyColumnDefs = [
  columnHelper.accessor('projectDisplayLabel', {
    header: 'Project',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('canRead', {
    header: 'Read',
    cell: (info) => cellAsReadOnlyCheckbox(info),
  }),
  columnHelper.accessor('canUpdate', {
    header: 'Update',
    cell: (info) => cellAsReadOnlyCheckbox(info),
  }),
  columnHelper.accessor('canCreate', {
    header: 'Create',
    cell: (info) => cellAsReadOnlyCheckbox(info),
  }),
  columnHelper.accessor('canDelete', {
    header: 'Delete',
    cell: (info) => cellAsReadOnlyCheckbox(info),
  }),
  columnHelper.accessor('canPublish', {
    header: 'Publish',
    cell: (info) => cellAsReadOnlyCheckbox(info),
  }),
  columnHelper.accessor('isProjectAdmin', {
    header: 'Project Admin',
    cell: (info) => cellAsReadOnlyCheckbox(info),
  }),
];