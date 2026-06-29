import { Alert } from 'react-bootstrap';

interface ImportErrorAlertProps {
  errors?: Record<string, string[]>; // Field errors: `{ field: [messages] }`
  title?: string;
}

// Converts field keys like "invalidCsvHeader" to "Invalid csv header"
function humanize(key: string): string {
  const text = key.replace(/([a-z0-9])([A-Z])/g, '$1 $2').toLowerCase();
  return text.charAt(0).toUpperCase() + text.slice(1);
}

// Alert displaying errors from a failed import or validation, grouped by key under one heading per key.
export const ImportErrorAlert = ({ errors, title }: ImportErrorAlertProps) => {
  if (!errors) return null;

  const groups = Object.entries(errors).filter(([, messages]) => messages?.length);

  // The request failed but didn't contain structured messages (eg. a 500 error)
  if (groups.length === 0) {
    return (
      <Alert variant="danger" className="mb-4">
        Something went wrong while processing your request. Please try again.
      </Alert>
    );
  }

  const totalCount = groups.reduce((sum, [, messages]) => sum + messages.length, 0);
  const heading =
    title ??
    `${totalCount} ${totalCount === 1 ? 'error' : 'errors'} prevented this import from being saved`;

  return (
    <Alert variant="danger" className="mb-4">
      <Alert.Heading as="h2" className="h6 mb-3">
        {heading}
      </Alert.Heading>
      {groups.map(([key, messages]) => (
        <div key={key} className="mb-2">
          {key !== 'base' && <div className="fw-semibold">{humanize(key)}</div>}
          <ul className="mb-0 ps-3">
            {messages.map((message, index) => (
              <li key={`${key}-${index}`}>{message}</li>
            ))}
          </ul>
        </div>
      ))}
    </Alert>
  );
};
