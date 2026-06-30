import { ImportJobForm } from '@/features/import-jobs/components/import-job-form';
import { Alert } from 'react-bootstrap';

const ImportJobsNewRoute = () => {
  return (
    <div>
      <Alert variant="info">
        Important Note: Please avoid using Microsoft Excel for CSV editing, imports, or exports.
        Excel doesn't handle UTF-8 properly.
      </Alert>
      <div className="pt-2">
        <ImportJobForm />
      </div>
    </div>
  );
};

export default ImportJobsNewRoute;
