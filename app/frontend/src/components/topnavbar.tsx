import React from 'react';
import { Nav, Navbar, Offcanvas, NavDropdown, Container } from 'react-bootstrap';
import { NavLink } from 'react-router';

const NAVBAR_EXPAND_SIZE = 'lg';

export default function TopNavbar() {
  return (
    <Navbar key={NAVBAR_EXPAND_SIZE} expand={NAVBAR_EXPAND_SIZE} className="bg-body-tertiary mb-3" data-bs-theme="dark">
      <Container>
        <Navbar.Brand href="#">
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
          {/* <Offcanvas.Header closeButton>
            <Offcanvas.Title id={`offcanvasNavbarLabel-expand-${NAVBAR_EXPAND_SIZE}`}>
              Offcanvas
            </Offcanvas.Title>
          </Offcanvas.Header> */}
          <Offcanvas.Body>
            <Nav>
              <Nav.Link href="#action1">Digital Objects</Nav.Link>
              <Nav.Link href="#action2">Projects</Nav.Link>
              <Nav.Link href="#action3">Controlled Vocabularies</Nav.Link>
              <NavDropdown
                title="Manage"
              >
                <NavDropdown.Item href="#action4">Dynamic Fields</NavDropdown.Item>
                <NavDropdown.Item href="#action5">
                  XML Datastreams
                </NavDropdown.Item>
                <NavDropdown.Item href="#action6">
                  Dynamic Field Categories
                </NavDropdown.Item>
                <NavDropdown.Item href="#action7">Publish Targets</NavDropdown.Item>
                <NavDropdown.Item href="#action8">PID Generators</NavDropdown.Item>
                <NavDropdown.Item as={NavLink} to="/users">
                  Users
                </NavDropdown.Item>
                <NavDropdown.Item href="#action10">Import Jobs</NavDropdown.Item>
                <NavDropdown.Item href="#action11">CSV Exports</NavDropdown.Item>
              </NavDropdown>
            </Nav>
            <Nav className="justify-content-end flex-grow-1">
              <NavDropdown title="User UID">
                <NavDropdown.Item as={NavLink} to="/settings">
                  Settings
                </NavDropdown.Item>
                <NavDropdown.Item href="#action13">
                  Assignments
                </NavDropdown.Item>
                <NavDropdown.Divider />
                <NavDropdown.Item href="#action14">
                  Historical Assignments
                </NavDropdown.Item>
                <NavDropdown.Item href="#action15">
                  System Information
                </NavDropdown.Item>
                <NavDropdown.Item href="#action16">
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