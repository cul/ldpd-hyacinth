
import { Editor, OnValidate } from '@monaco-editor/react';

type JSONEditorProps = {
  value: string;
  onChange: (value: string) => void;
  onValidate?: OnValidate;
  className?: string;
};

export const JSONEditor = ({ value, onChange, onValidate, className }: JSONEditorProps) => {
  return (
    <Editor
      className={`border w-100 ${className ?? ''}`}
      height="400px"
      defaultLanguage="json"
      value={value}
      defaultValue='{}'
      onChange={(val) => onChange(val ?? '')}
      onValidate={onValidate}
      options={{
        minimap: { enabled: false },
        fontSize: 14,
      }}
    />
  );
};