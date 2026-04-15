
import { Editor as MonacoEditor, OnValidate } from '@monaco-editor/react';

type EditorProps = {
  value: string;
  onChange: (value: string) => void;
  onValidate?: OnValidate;
};

// TODO: Make a reusable component, accept different languages
export const Editor = ({ value, onChange, onValidate }: EditorProps) => {
  // const validationTest = (markers: unknown[]) => {
  //   markers.forEach((marker) => console.log('onValidate:', marker));
  // }

  return (
    <MonacoEditor
      className="border w-100"
      height="500px"
      defaultLanguage="json"
      value={value}
      onChange={(val) => onChange(val ?? '')}
      // onValidate={validationTest}
      onValidate={onValidate}
      options={{
        minimap: { enabled: false },
        fontSize: 14,
      }}
    />
  );
};