import { Outlet, useLocation, useNavigate, useResolvedPath } from 'react-router';
import { Container, Button } from 'react-bootstrap';
import { ArrowLeft, Plus } from 'react-bootstrap-icons';

type FeatureLayoutProps = {
  featureName: string;
  featureNamePlural?: string;
};

// This is a generic layout that can be reused for different features (Users, Publish Targets, etc.)
// It renders a simple navigation header with a button to create a new feature or go back to the feature list
const FeatureLayout = ({ featureName, featureNamePlural = `${featureName}s` }: FeatureLayoutProps) => {
  const location = useLocation();
  const navigate = useNavigate();
  const resolvedPath = useResolvedPath('.');
  const isIndexPage = location.pathname === resolvedPath.pathname;

  return (
    <Container className="py-2">
      <div className="d-flex justify-content-between align-items-center mb-4">
        {isIndexPage ? (
          <Button
            variant="primary"
            onClick={() => navigate('new')}
            className="d-flex align-items-center gap-1"
          >
            <Plus size={20} />
            Create New {featureName}
          </Button>
        ) : (
          <Button
            variant="outline-secondary"
            onClick={() => navigate('.')}
            className="d-flex align-items-center gap-1"
          >
            <ArrowLeft size={18} />
            Back to All {featureNamePlural}
          </Button>
        )}
      </div>
      <Outlet />
    </Container>
  );
};

export default FeatureLayout;