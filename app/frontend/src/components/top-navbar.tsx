import { useRef } from 'react';
import { Nav, Navbar, Offcanvas, NavDropdown, Container } from 'react-bootstrap';
import { NavLink } from 'react-router';
import { useCurrentUser, AUTH_QUERY_KEY } from '@/lib/auth';
import { useQueryClient } from '@tanstack/react-query';
import { Authorization, ROLES } from '@/lib/authorization';

const NAVBAR_EXPAND_SIZE = 'lg';

// Links to the old UI should be updated to use React Router navigation instead of full page loads
// after their corresponding routes/components have been implemented in the new UI.
export default function TopNavbar() {
  const { data: user } = useCurrentUser();

  const queryClient = useQueryClient();
  const logoutFormRef = useRef<HTMLFormElement>(null);

  const handleLogout = () => {
    queryClient.invalidateQueries({ queryKey: AUTH_QUERY_KEY });
    queryClient.clear();
    
    logoutFormRef.current?.submit();
  };

  return (
    <Navbar key={NAVBAR_EXPAND_SIZE} expand={NAVBAR_EXPAND_SIZE} className="bg-body-tertiary mb-3" data-bs-theme="dark">
      <Container>
        <Navbar.Brand as={NavLink} to="/">
          <img
            src="/../assets/hyacinth-logo.png"
            width="30"
            height="30"
            className="d-inline-block align-top"
            alt="Hyacinth logo"
          />
          Hyacinth
        </Navbar.Brand>
        <Navbar.Toggle aria-controls={`offcanvasNavbar-expand-${NAVBAR_EXPAND_SIZE}`} />
        <Navbar.Offcanvas
          id={`offcanvasNavbar-expand-${NAVBAR_EXPAND_SIZE}`}
          aria-labelledby={`offcanvasNavbarLabel-expand-${NAVBAR_EXPAND_SIZE}`}
          placement="end"
        >
          <Offcanvas.Body>
            <Nav>
              <Nav.Link href="/digital_objects">Digital Objects</Nav.Link>
              {user?.adminForAtLeastOneProject && (
                <Nav.Link href="/projects">Projects</Nav.Link>
              )}
              {user?.canEditAtLeastOneControlledVocabulary && (
                <Nav.Link href="/controlled_vocabularies">Controlled Vocabularies</Nav.Link>
              )}
              <NavDropdown title="Manage">
                <Authorization allowedRoles={[ROLES.ADMIN]}>
                  <NavDropdown.Item href="/dynamic_fields">Dynamic Fields</NavDropdown.Item>
                  <NavDropdown.Item href="/xml_datastreams">
                    XML Datastreams
                  </NavDropdown.Item>
                  <NavDropdown.Item href="/dynamic_field_group_categories">
                    Dynamic Field Categories
                  </NavDropdown.Item>
                  {/* TODO: Add query params */}
                  <NavDropdown.Item href='/digital_objects'>
                    Publish Targets
                  </NavDropdown.Item>
                  <NavDropdown.Item href="/pid_generators">PID Generators</NavDropdown.Item>
                  <NavDropdown.Item as={NavLink} to="/users" end>
                    Users
                  </NavDropdown.Item>
                </Authorization>
                <NavDropdown.Item href="/import_jobs">Import Jobs</NavDropdown.Item>
                <NavDropdown.Item href="/csv_exports">CSV Exports</NavDropdown.Item>
              </NavDropdown>
            </Nav>
            <Nav className="justify-content-end flex-grow-1">
              <NavDropdown title={`${user?.firstName} ${user?.lastName}`} align="end">
                {/* Use 'end' to ensure this link is only active on the exact /settings path */}
                <NavDropdown.Item as={NavLink} to="/settings" end>
                  Settings
                </NavDropdown.Item>
                <NavDropdown.Item as={NavLink} to="/settings/project-permissions">
                  Project Permissions
                </NavDropdown.Item>
                <NavDropdown.Item href="/assignments">
                  Assignments
                </NavDropdown.Item>
                <Authorization allowedRoles={[ROLES.ADMIN]}>
                  <NavDropdown.Item href="/archived_assignments">
                    Historical Assignments
                  </NavDropdown.Item>
                  <NavDropdown.Item href="/system_information">
                    System Information
                  </NavDropdown.Item>
                  <NavDropdown.Divider />
                </Authorization>
                <NavDropdown.Item onClick={handleLogout}>
                  Sign Out
                </NavDropdown.Item>
                <form
                  ref={logoutFormRef}
                  action="/users/sign_out"
                  method="post"
                  className="d-none"
                >
                  <input type="hidden" name="_method" value="delete" />
                  <input
                    type="hidden"
                    name="authenticity_token"
                    value={document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''}
                  />
                </form>
              </NavDropdown>
            </Nav>
          </Offcanvas.Body>
        </Navbar.Offcanvas>
      </Container>
    </Navbar>
  )
}