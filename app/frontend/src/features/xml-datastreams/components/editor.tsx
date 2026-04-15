
import { Editor as MonacoEditor } from '@monaco-editor/react';

export const Editor = ({ value }: { value: string }) => {
  return (
    <MonacoEditor
      className={`border w-100`}
      height="500px"
      defaultLanguage="xml"
      value={value}
      options={{
        minimap: { enabled: false },
        fontSize: 14
      }}
    // onChange={}
    />
  );
};