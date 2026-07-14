import { Editor, OnValidate } from '@monaco-editor/react';

type JSONEditorProps = {
  value: string;
  onChange?: (value: string) => void;
  onValidate?: OnValidate;
  className?: string;
  ariaLabel?: string;
  readOnly?: boolean;
};

export const JSONEditor = ({
  value,
  onChange,
  onValidate,
  className,
  ariaLabel,
  readOnly = false,
}: JSONEditorProps) => {
  return (
    <Editor
      className={`border w-100 ${className ?? ''}`}
      height="400px"
      defaultLanguage="json"
      value={value}
      defaultValue="{}"
      onChange={(val) => onChange?.(val ?? '')}
      onValidate={onValidate}
      options={{
        readOnly,
        minimap: { enabled: false },
        fontSize: 14,
        ariaLabel,
      }}
    />
  );
};
