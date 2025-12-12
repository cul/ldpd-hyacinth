import React from 'react';
import { Nav, Form, Navbar, Offcanvas, NavDropdown, Container, Button } from 'react-bootstrap';

const NAVBAR_EXPAND_SIZE = 'lg';

export default function App() {
  return (
    <div>
      <Navbar key={NAVBAR_EXPAND_SIZE} expand={NAVBAR_EXPAND_SIZE} className="bg-body-tertiary mb-3" data-bs-theme="dark">
          <Container fluid>
            <Navbar.Brand href="#">Navbar Offcanvas</Navbar.Brand>
            <Navbar.Toggle aria-controls={`offcanvasNavbar-expand-${NAVBAR_EXPAND_SIZE}`} />
            <Navbar.Offcanvas
              id={`offcanvasNavbar-expand-${NAVBAR_EXPAND_SIZE}`}
              aria-labelledby={`offcanvasNavbarLabel-expand-${NAVBAR_EXPAND_SIZE}`}
              placement="end"
            >
              <Offcanvas.Header closeButton>
                <Offcanvas.Title id={`offcanvasNavbarLabel-expand-${NAVBAR_EXPAND_SIZE}`}>
                  Offcanvas
                </Offcanvas.Title>
              </Offcanvas.Header>
              <Offcanvas.Body>
                <Nav className="justify-content-end flex-grow-1 pe-3">
                  <Nav.Link href="#action1">Home</Nav.Link>
                  <Nav.Link href="#action2">Link</Nav.Link>
                  <NavDropdown
                    title="Dropdown"
                    id={`offcanvasNavbarDropdown-expand-${NAVBAR_EXPAND_SIZE}`}
                  >
                    <NavDropdown.Item href="#action3">Action</NavDropdown.Item>
                    <NavDropdown.Item href="#action4">
                      Another action
                    </NavDropdown.Item>
                    <NavDropdown.Divider />
                    <NavDropdown.Item href="#action5">
                      Something else here
                    </NavDropdown.Item>
                  </NavDropdown>
                </Nav>
              </Offcanvas.Body>
            </Navbar.Offcanvas>
          </Container>
        </Navbar>
    </div>
  );
}