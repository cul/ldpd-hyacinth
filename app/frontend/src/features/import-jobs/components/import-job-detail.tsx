import { Table as BTable } from 'react-bootstrap';
import { Link } from 'react-router';
import { ImportJob } from '@/types/api';
import { formatLocalDateTime } from '@/utils/format';

interface ImportJobDetailProps {
  importJob: ImportJob;
}

export const ImportJobDetail = ({ importJob }: ImportJobDetailProps) => {
  return (
    <div>
      <div className="d-flex align-items-center gap-2 mb-4">
        <h2 className="mb-0">{importJob.name}</h2>
        <span className="text-muted">#{importJob.id}</span>
      </div>

      {/* TODO: Extract into separate components */}
      <div className="mb-4">
        <div className="mb-3">
          <dt className="fw-semibold text-secondary small text-uppercase mb-1">Created on</dt>
          <dd className="mb-0">{formatLocalDateTime(importJob.createdAt)}</dd>
        </div>

        <div className="mb-3">
          <dt className="fw-semibold text-secondary small text-uppercase mb-1">User</dt>
          <dd className="mb-0">
            {importJob.user.fullName} ({importJob.user.uid})
          </dd>
        </div>

        <div className="mb-3">
          <dt className="fw-semibold text-secondary small text-uppercase mb-1">Priority</dt>
          <dd className="mb-0">{importJob.priority}</dd>
        </div>

        <div className="mb-3">
          <dt className="fw-semibold text-secondary small text-uppercase mb-1">
            Restore archived S3 objects for new assets
          </dt>
          <dd className="mb-0">{importJob.restoreArchivedS3ObjectsForNewAssets ? 'Yes' : 'No'}</dd>
        </div>

        <div className="mb-3">
          <dt className="fw-semibold text-secondary small text-uppercase mb-1">
            Download Original CSV File
          </dt>
          <dd className="mb-0">
            {/* <a href={importJob.originalCsvUrl} download>
            Download
          </a> */}
          </dd>
        </div>

        <div className="mb-3">
          <dt className="fw-semibold text-secondary small text-uppercase mb-1">
            Download CSV File Without Successful Rows
          </dt>
          <dd className="mb-0">
            {/* <a href={importJob.csvWithoutSuccessfulRowsUrl} download>
            Download
          </a> */}
          </dd>
        </div>
      </div>

      <BTable striped bordered responsive>
        <thead>
          <tr>
            <th>Pending rows</th>
            <th>Successful row imports</th>
            <th>Failed row imports</th>
            <th>Total number of rows</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>{importJob.pendingCount}</td>
            <td>{importJob.successCount}</td>
            <td>{importJob.failureCount}</td>
            <td>
              <Link
                to={{ pathname: `digital-object-imports` }}
                className="link-underline link-underline-opacity-0 link-underline-opacity-75-hover"
              >
                {importJob.pendingCount + importJob.successCount + importJob.failureCount}
              </Link>
            </td>
          </tr>
        </tbody>
      </BTable>
    </div>
  );
};
