import { Outlet, useLocation, useNavigate } from 'react-router';
import { Container, Button } from 'react-bootstrap';
import { ArrowLeft, Plus } from 'react-bootstrap-icons';

export default function UsersLayout() {
  const location = useLocation();
  const navigate = useNavigate();
  const isIndexPage = location.pathname === '/users';

  return (
    <Container className="py-2">
      <div className="d-flex justify-content-between align-items-center mb-4">
        {isIndexPage ? (
          <Button
            variant="primary"
            onClick={() => navigate('/users/new')}
            className="d-flex align-items-center gap-1"
          >
            <Plus size={20} />
            Create New User
          </Button>
        ) : (
          <Button
            variant="outline-secondary"
            onClick={() => navigate('/users')}
            className="d-flex align-items-center gap-1"
          >
            <ArrowLeft size={18} />
            Back to All Users
          </Button>
        )}
      </div>
      <Outlet />
    </Container>
  );
};