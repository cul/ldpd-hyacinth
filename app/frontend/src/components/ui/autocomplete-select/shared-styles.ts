import type { GroupBase, StylesConfig } from 'react-select';
import type { SelectOption } from './types';

/**
 * Shared react-select styles that align with Bootstrap form controls.
 *
 * Structural styles (sizing, padding, border-radius) live in
 * src/styles/react-select-customizations.scss via the "react-select"
 * classNamePrefix. This config handles state-dependent styles (focus,
 * hover) that require access to react-select's `state` object.
*/
export const sharedStyles: StylesConfig<SelectOption, boolean, GroupBase<SelectOption>> = {
  control: (base, state) => ({
    ...base,
    borderColor: state.isFocused
      ? 'rgba(var(--bs-primary-rgb), 0.5)'
      : 'var(--bs-border-color)',
    boxShadow: state.isFocused
      ? '0 0 0 0.25rem rgba(var(--bs-primary-rgb), 0.25)'
      : 'none',
    '&:hover': {
      borderColor: state.isFocused
        ? 'rgba(var(--bs-primary-rgb), 0.5)'
        : 'var(--bs-border-color)',
    },
  }),
  menuPortal: (base) => ({ ...base, zIndex: 9999 }),
};
