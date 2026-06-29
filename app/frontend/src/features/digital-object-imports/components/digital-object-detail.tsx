import { Link, useNavigate } from 'react-router';
import { Badge, Button, Card, Col, Row } from 'react-bootstrap';
import { JSONEditor } from '@/components/ui/json-editor/json-editor';
import { DigitalObjectImport } from '@/types/api';
import { ArrowLeft } from 'react-bootstrap-icons';

const STATUS_VARIANT: Record<string, string> = {
  pending: 'secondary',
  success: 'success',
  failure: 'danger',
};

interface DigitalObjectDetailProps {
  digitalObjectImport: DigitalObjectImport;
}

export const DigitalObjectDetail = ({ digitalObjectImport }: DigitalObjectDetailProps) => {
  const {
    id,
    importJobId,
    importJobName,
    csvRowNumber,
    status,
    digitalObjectData,
    digitalObjectErrors,
    prerequisiteCsvRowNumbers,
    createdAt,
    updatedAt,
  } = digitalObjectImport;

  const formatDigitalObjectData = (raw: string) => {
    try {
      return JSON.stringify(JSON.parse(raw), null, 2);
    } catch {
      return raw;
    }
  };

  const hasErrors = digitalObjectErrors && digitalObjectErrors.length > 0;
  const formatted = formatDigitalObjectData(digitalObjectData);

  const navigate = useNavigate();

  return (
    <div>
      <Button
        variant="outline-secondary"
        size="sm"
        className="d-flex align-items-center gap-1"
        onClick={() => navigate('..', { relative: 'path' })}
      >
        <ArrowLeft size={18} />
        Back to the list of digital object imports
      </Button>

      <div className="d-flex align-items-center gap-2 my-4">
        <h2 className="mb-0">Digital Object Import</h2>
        <span className="text-muted">#{id}</span>
        <Badge bg={STATUS_VARIANT[status]} className="ms-1 text-capitalize">
          {status}
        </Badge>
      </div>

      <Card className="mb-4">
        <Card.Body>
          <Row className="g-3">
            <Col md={4}>
              <dt className="fw-semibold text-secondary small text-uppercase mb-1">
                CSV Row Number
              </dt>
              <dd className="mb-0">{csvRowNumber}</dd>
            </Col>
            <Col md={4}>
              <dt className="fw-semibold text-secondary small text-uppercase mb-1">Import Job</dt>
              <dd className="mb-0">
                <Link to={`/import-jobs/${importJobId}`}>{importJobName}</Link>
              </dd>
            </Col>
            <Col md={4}>
              <dt className="fw-semibold text-secondary small text-uppercase mb-1">
                Prerequisite CSV Row Numbers
              </dt>
              <dd className="mb-0">
                {prerequisiteCsvRowNumbers && prerequisiteCsvRowNumbers.length > 0
                  ? prerequisiteCsvRowNumbers.join(', ')
                  : 'None'}
              </dd>
            </Col>
            <Col md={4}>
              <dt className="fw-semibold text-secondary small text-uppercase mb-1">Created</dt>
              <dd className="mb-0">{createdAt}</dd>
            </Col>
            <Col md={4}>
              <dt className="fw-semibold text-secondary small text-uppercase mb-1">Updated</dt>
              <dd className="mb-0">{updatedAt}</dd>
            </Col>
          </Row>
        </Card.Body>
      </Card>

      {hasErrors && (
        <Card className="mb-4 border-danger border-opacity-25">
          <Card.Header className="bg-danger-subtle text-danger-emphasis fw-semibold">
            Errors
          </Card.Header>
          <Card.Body>
            <ul className="mb-0">
              {digitalObjectErrors.map((error, i) => (
                <li key={i}>{error}</li>
              ))}
            </ul>
          </Card.Body>
        </Card>
      )}

      {/* TODO: Add copy to clipboard */}
      <Card>
        <Card.Header className="d-flex align-items-center justify-content-between">
          <span className="fw-semibold">Digital Object Data (read only)</span>
          <Badge bg="light" text="dark">
            JSON
          </Badge>
        </Card.Header>
        <Card.Body className="p-0">
          <JSONEditor
            value={formatted}
            ariaLabel={`Digital object data for import ${id}`}
            readOnly
          />
        </Card.Body>
      </Card>
    </div>
  );
};
