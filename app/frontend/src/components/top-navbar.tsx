import React from 'react';
import { Nav, Navbar, Offcanvas, NavDropdown, Container } from 'react-bootstrap';
import { NavLink } from 'react-router';
// import { api } from '@/lib/api-client';

const NAVBAR_EXPAND_SIZE = 'lg';

// This will not work as-is because we don't get JSON responses from Rails for sign out requests
// const logout = () => {
//   api.delete('/users/sign_out');
// };

// Links to the old UI should be updated to use React Router navigation instead of full page loads
// after their corresponding routes/components have been implemented in the new UI.
export default function TopNavbar() {
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
              <Nav.Link href="/projects">Projects</Nav.Link>
              <Nav.Link href="/controlled_vocabularies">Controlled Vocabularies</Nav.Link>
              <NavDropdown title="Manage">
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
                <NavDropdown.Item as={NavLink} to="/users">
                  Users
                </NavDropdown.Item>
                <NavDropdown.Item href="/import_jobs">Import Jobs</NavDropdown.Item>
                <NavDropdown.Item href="/csv_exports">CSV Exports</NavDropdown.Item>
              </NavDropdown>
            </Nav>
            <Nav className="justify-content-end flex-grow-1">
              <NavDropdown title="User UID">
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
                <NavDropdown.Item href="/archived_assignments">
                  Historical Assignments
                </NavDropdown.Item>
                <NavDropdown.Item href="/system_information">
                  System Information
                </NavDropdown.Item>
                <NavDropdown.Divider />

                {/* No href for logout */}
                <NavDropdown.Item>
                  Sign Out
                </NavDropdown.Item>
              </NavDropdown>
            </Nav>
          </Offcanvas.Body>
        </Navbar.Offcanvas>
      </Container>
    </Navbar>
  )
}