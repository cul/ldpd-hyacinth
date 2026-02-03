import React from 'react';
import { Form, Col } from 'react-bootstrap';

export type FieldWrapperProps = {
  label?: string;
  error?: string[];
  children: React.ReactNode;
  md?: number;
  className?: string;
  controlId?: string;
};

/**
 * FieldWrapperPassThroughProps is used by Input and Select components.
 * It takes all props from FieldWrapperProps EXCEPT 'children' (using Omit).
 * 
 * The wrapper's 'children' is the actual input/select element,
 * but we want Input/Select to accept wrapper props like 'label' and 'error'
 * without requiring them to pass a 'children' prop.
 */
export type FieldWrapperPassThroughProps = Omit<FieldWrapperProps, 'children'>;

export const FieldWrapper = ({
  label,
  error,
  children,
  md,
  className,
  controlId,
}: FieldWrapperProps) => {
  return (
    <Form.Group
      as={Col}
      md={md}
      controlId={controlId}
      className={className}
    >
      {label && <Form.Label>{label}</Form.Label>}
      {children}
      {error && (
        <Form.Control.Feedback type="invalid">
          {error.join(', ')}
        </Form.Control.Feedback>
      )}
    </Form.Group>
  );
};