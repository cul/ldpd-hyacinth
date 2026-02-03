import React from 'react';
import { Form } from 'react-bootstrap';
import { FieldWrapper, type FieldWrapperPassThroughProps } from './field-wrapper';

// Omit 'size' (conflicting with HTML attribute) and 'onChange' to redefine them later
type BaseInputProps = Omit<React.InputHTMLAttributes<HTMLInputElement>, 'size' | 'onChange'>;

/**
 * InputProps: Combine multiple type definitions:
 * 1. All HTML input attributes (except size & onChange)
 * 2. All wrapper props (label, error, md, etc.)
 * 3. Our custom props defined in the object below
 */
export type InputProps = BaseInputProps &
  FieldWrapperPassThroughProps & {
    name: string;
    value?: string | number;
    error?: string[];
    onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
    size?: 'sm' | 'lg';
  };

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, md, controlId: customControlId, placeholder, type = 'text', ...props }, ref) => {
    const controlId = customControlId || `formGrid${props.name.charAt(0).toUpperCase()}${props.name.slice(1)}`;

    return (
      <FieldWrapper label={label} error={error} md={md} controlId={controlId}>
        <Form.Control
          ref={ref}
          type={type}
          placeholder={placeholder || (label ? `Enter ${label.toLowerCase()}` : '')}
          isInvalid={!!error}
          {...props}
        />
      </FieldWrapper>
    );
  }
);

Input.displayName = 'Input';