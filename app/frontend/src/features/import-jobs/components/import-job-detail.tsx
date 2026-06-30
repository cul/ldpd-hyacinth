import { Table as BTable, Button, Badge, Card, Row, Col } from 'react-bootstrap';
import { Link } from 'react-router';
import { ImportJob } from '@/types/api';
import { formatLocalDateTime } from '@/utils/format';
import {
  getCsvWithoutSuccessfulRowsDownloadUrl,
  getOriginalCsvDownloadUrl,
} from '../api/download-csv';

interface ImportJobDetailProps {
  importJob: ImportJob;
}

const statusVariant = (status: string): string =>
  ({
    'successfully completed': 'success',
    'complete with failures': 'warning',
    incomplete: 'secondary',
  })[status?.toLowerCase()] ?? 'secondary';

export const ImportJobDetail = ({ importJob }: ImportJobDetailProps) => {
  const { pendingCount, successCount, failureCount } = importJob;
  const totalCount = pendingCount + successCount + failureCount;

  const stats = [
    { label: 'Successful', count: successCount, variant: 'success', filterName: 'success' },
    { label: 'Pending', count: pendingCount, variant: 'secondary', filterName: 'pending' },
    { label: 'Failed', count: failureCount, variant: 'danger', filterName: 'failure' },
  ];

  return (
    <div>
      <div className="d-flex align-items-center gap-2 mb-2">
        <h2 className="mb-0">{importJob.name}</h2>
        <span className="text-muted">#{importJob.id}</span>
        <Badge bg={statusVariant(importJob.status)} className="ms-auto text-uppercase">
          {importJob.status}
        </Badge>
      </div>

      <div className="d-flex flex-wrap gap-4 text-muted small border-bottom pb-3 mb-4">
        <span>
          Uploaded{' '}
          <span className="text-body fw-semibold">{formatLocalDateTime(importJob.createdAt)}</span>
        </span>
        <span>
          by <span className="text-body fw-semibold">{importJob.user.fullName}</span> (
          {importJob.user.uid})
        </span>
        <span>
          Priority{' '}
          <span className="text-body fw-semibold text-capitalize">{importJob.priority}</span>
        </span>
      </div>

      <Card className="mb-4">
        <Card.Body>
          <Card.Title as="h5" className="mb-3">
            Job details
          </Card.Title>
          <BTable borderless responsive className="mb-0 align-middle">
            <tbody>
              <tr>
                <th className="text-secondary small text-uppercase fw-semibold w-50 w-md-25">
                  Restore archived S3 objects for new assets
                </th>
                <td>{importJob.restoreArchivedS3ObjectsForNewAssets ? 'Yes' : 'No'}</td>
              </tr>
              {importJob.pathToCsvFile && (
                <>
                  <tr>
                    <th className="text-secondary small text-uppercase fw-semibold">
                      Original CSV file
                    </th>
                    <td>
                      <Button
                        as="a"
                        href={getOriginalCsvDownloadUrl(importJob.id)}
                        variant="link"
                        className="p-0"
                      >
                        Download
                      </Button>
                    </td>
                  </tr>
                  <tr>
                    <th className="text-secondary small text-uppercase fw-semibold">
                      CSV without successful rows
                    </th>
                    <td>
                      <Button
                        as="a"
                        href={getCsvWithoutSuccessfulRowsDownloadUrl(importJob.id)}
                        variant="link"
                        className="p-0"
                      >
                        Download
                      </Button>
                    </td>
                  </tr>
                </>
              )}
            </tbody>
          </BTable>
        </Card.Body>
      </Card>

      <Card className="mb-4">
        <Card.Body>
          <div className="d-flex justify-content-between align-items-baseline mb-3">
            <Card.Title as="h5" className="mb-0">
              Row imports
            </Card.Title>
            <Link
              to={{ pathname: 'digital-object-imports' }}
              className="small link-underline link-underline-opacity-0 link-underline-opacity-75-hover"
            >
              View all {totalCount} rows
            </Link>
          </div>

          <Row className="g-3 text-center">
            {stats.map(({ label, count, variant, filterName }) => (
              <Col xs={4} key={label}>
                <Link
                  to={{
                    pathname: 'digital-object-imports',
                    search: `?status=${filterName}`,
                  }}
                  className="text-decoration-none"
                >
                  <Card className="h-100 border-0 bg-light">
                    <Card.Body className="py-3">
                      <div className={`fs-3 fw-bold text-${variant}`}>{count}</div>
                      <div className="text-muted small text-uppercase">{label}</div>
                    </Card.Body>
                  </Card>
                </Link>
              </Col>
            ))}
          </Row>
        </Card.Body>
      </Card>
    </div>
  );
};
