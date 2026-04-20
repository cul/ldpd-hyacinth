// Mock Monaco Editor since it doesn't work in jsdom
export const Editor = ({ value, onChange, onValidate, options }: {
  value: string,
  onChange: (value: string) => void,
  onValidate: (markers: unknown) => void,
  options?: { ariaLabel?: string }
}) => (
  <textarea
    value={value}
    aria-label={options?.ariaLabel}
    onChange={(e) => {
      const val = e.target.value;
      onChange(val)
      if (onValidate) {
        try {
          JSON.parse(val)
          onValidate([])
        } catch {
          onValidate([{ message: 'Invalid JSON' }])
        }
      }
    }}
  />
);