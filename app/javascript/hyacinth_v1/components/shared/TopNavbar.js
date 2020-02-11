import React from 'react';
import PropTypes from 'prop-types';
import { Navbar, Nav, NavDropdown } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap';

import Constants from '../../Constants';
import { Can } from '../../utils/abilityContext';

function TopNavbar(props) {
  const { user } = props;

  const signOut = (e) => {
    e.preventDefault(); // prevent hashchange when sign out link is clicked

    const postData = {};
    postData[document.querySelector("meta[name='csrf-param']").getAttribute('content')] = document.querySelector("meta[name='csrf-token']").getAttribute('content');

    fetch(Constants.SIGN_OUT_PATH, {
      method: 'delete',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(postData),
    }).then((response) => {
      if (response.status) {
        window.location.href = '/';
      } else {
        // eslint-disable-next-line no-alert
        window.alert('An unexpected error occurred during sign out.');
      }
    });
  };

  return (
    <Navbar collapseOnSelect id="top-navbar" variant="dark" bg="primary" expand="md" className="mb-3 px-2 p-1">
      <Navbar.Brand href="/">Hyacinth</Navbar.Brand>

      <Navbar.Toggle aria-controls="responsive-navbar-nav" />

      <Navbar.Collapse id="responsive-navbar-nav">
        <Nav className="mr-auto">
          <LinkContainer to="/digital_objects">
            <Nav.Link>Digital Objects</Nav.Link>
          </LinkContainer>

          <NavDropdown title="Manage">
            <LinkContainer to="/projects">
              <NavDropdown.Item>Projects</NavDropdown.Item>
            </LinkContainer>

            <Can I="manage" a="Vocabulary">
              <LinkContainer to="/controlled_vocabularies">
                <NavDropdown.Item>Controlled Vocabularies</NavDropdown.Item>
              </LinkContainer>
            </Can>

            <LinkContainer to="/assignments">
              <NavDropdown.Item>Assignments</NavDropdown.Item>
            </LinkContainer>

            <NavDropdown.Divider />

            <LinkContainer to="/export-jobs">
              <NavDropdown.Item>Export Jobs</NavDropdown.Item>
            </LinkContainer>

            <LinkContainer to="/import-jobs">
              <NavDropdown.Item>Import Jobs</NavDropdown.Item>
            </LinkContainer>
          </NavDropdown>

          <Can I="manage" a="User">
            <NavDropdown title="Admin">
              <LinkContainer to="/users">
                <NavDropdown.Item>Users</NavDropdown.Item>
              </LinkContainer>

              <Can I="manage" a="all">
                <NavDropdown.Divider />

                <LinkContainer to="/dynamic_fields">
                  <NavDropdown.Item>Dynamic Fields</NavDropdown.Item>
                </LinkContainer>

                <LinkContainer to="/field_export_profiles">
                  <NavDropdown.Item>Field Export Profiles</NavDropdown.Item>
                </LinkContainer>

                <NavDropdown.Divider />

                <LinkContainer to="/system_information">
                  <NavDropdown.Item>System Information</NavDropdown.Item>
                </LinkContainer>
              </Can>
            </NavDropdown>
          </Can>
        </Nav>

        <Nav>
          <NavDropdown alignRight title={`${user.firstName} ${user.lastName}`}>
            <LinkContainer to={`/users/${user.id}/edit`}>
              <NavDropdown.Item>Profile</NavDropdown.Item>
            </LinkContainer>

            <NavDropdown.Divider />

            <NavDropdown.Item onClick={signOut}>Sign Out</NavDropdown.Item>
          </NavDropdown>
        </Nav>
      </Navbar.Collapse>
    </Navbar>
  );
}

TopNavbar.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
  }).isRequired,
};

export default TopNavbar;
