import { Outlet, useLocation, useNavigate } from 'react-router';
import { Container, Button } from 'react-bootstrap';
import { ArrowLeft, Plus } from 'react-bootstrap-icons';

// TODO: This is identical to UsersLayout except for the paths and labels, maybe we can make a generic layout component
// if we end up needing more layouts with this same pattern
const PublishTargetsLayout = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const isIndexPage = location.pathname === '/publish-targets';

  return (
    <Container className="py-2">
      <div className="d-flex justify-content-between align-items-center mb-4">
        {isIndexPage ? (
          <Button
            variant="primary"
            onClick={() => navigate('/publish-targets/new')}
            className="d-flex align-items-center gap-1"
          >
            <Plus size={20} />
            Create New Publish Target
          </Button>
        ) : (
          <Button
            variant="outline-secondary"
            onClick={() => navigate('/publish-targets')}
            className="d-flex align-items-center gap-1"
          >
            <ArrowLeft size={18} />
            Back to All Publish Targets
          </Button>
        )}
      </div>
      <Outlet />
    </Container>
  );
};

export default PublishTargetsLayout;
