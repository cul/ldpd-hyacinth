import React from 'react';
import { Form } from 'react-bootstrap';
import FieldWrapper, {FieldWrapperPassThroughProps } from './FieldWrapper';

// Omit 'size' (conflicting with HTML attribute) and 'onChange' to redefine them later
type BaseSelectProps = Omit<React.SelectHTMLAttributes<HTMLSelectElement>, 'size' | 'onChange'>;

/**
 * SelectProps: Combine multiple type definitions:
 * 1. All HTML select attributes (except size & onChange)
 * 2. All wrapper props (label, error, md, etc.)
 * 3. Our custom props defined in the object below
 */
export type SelectProps = BaseSelectProps &
  FieldWrapperPassThroughProps & {
    name: string;
    value?: string;
    error?: string[];
    onChange: (e: React.ChangeEvent<HTMLSelectElement>) => void;
    children: React.ReactNode;
    size?: 'sm' | 'lg';
  };

export default function Select({
  label,
  error,
  md,
  controlId: customControlId,
  children,
  ...props
}: SelectProps, ref: React.Ref<HTMLSelectElement>) {
  const controlId = customControlId || `formGrid${props.name.charAt(0).toUpperCase()}${props.name.slice(1)}`;

  return (
    <FieldWrapper label={label} error={error} md={md} controlId={controlId}>
      <Form.Select ref={ref} isInvalid={!!error} {...props}>
        {children}
      </Form.Select>
    </FieldWrapper>
  );
}
