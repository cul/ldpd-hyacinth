import React from 'react'
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import Constants from 'hyacinth_ui_v1/Constants'
import { Navbar, Nav, NavDropdown } from "react-bootstrap";
import { LinkContainer } from "react-router-bootstrap";
import { Can } from 'hyacinth_ui_v1/util/ability_context';

export default class TopNavbar extends React.Component {
  signOut(e) {
    e.preventDefault(); // prevent hashchange when sign out link is clicked
    console.log('called sign out function!');

    // let methodInputElement = document.createElement('input');
    // methodInputElement.type = 'hidden';
    // methodInputElement.name = '_method';
    // methodInputElement.value = 'delete';
    //
    // let authenticityTokenInputElement = document.createElement('input');
    // authenticityTokenInputElement.type = 'hidden';
    // authenticityTokenInputElement.name = document.querySelector("meta[name='csrf-param']").getAttribute("content");
    // authenticityTokenInputElement.value = document.querySelector("meta[name='csrf-token']").getAttribute("content");
    //
    // let formElement = document.createElement('form');
    // formElement.method = 'post';
    // formElement.action = Constants.SIGN_OUT_PATH;
    // formElement.appendChild(methodInputElement);
    // formElement.appendChild(authenticityTokenInputElement);
    //
    // document.body.appendChild(formElement);
    // formElement.submit();

    let postData = {};
    postData[document.querySelector("meta[name='csrf-param']").getAttribute("content")] =
      document.querySelector("meta[name='csrf-token']").getAttribute("content");

    fetch(Constants.SIGN_OUT_PATH, {
      method: 'delete',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(postData)
    }).then(function(response) {
      if(response.status) {
        location.href = '/';
      } else {
        console.log(response);
        alert('An unexpected error occurred during sign out.');
      }
    });
  }

  render() {
    return (
      <Navbar collapseOnSelect id="top-navbar" variant="dark" bg="dark" expand="md">
        <Navbar.Brand href="/">Hyacinth</Navbar.Brand>

        <Navbar.Toggle aria-controls="responsive-navbar-nav" />

        <Navbar.Collapse id="responsive-navbar-nav">
          <Nav className="mr-auto">
            <LinkContainer to={'/digital-objects'}>
              <Nav.Link>Digital Objects</Nav.Link>
            </LinkContainer>

            <NavDropdown title="Manage">
              <LinkContainer to='/projects'>
                <NavDropdown.Item>Projects</NavDropdown.Item>
              </LinkContainer>

              <Can I="manage" a="Vocabulary">
                <LinkContainer to='/controlled-vocabularies'>
                  <NavDropdown.Item>Controlled Vocabularies</NavDropdown.Item>
                </LinkContainer>
              </Can>

              <LinkContainer to='/assignments'>
                <NavDropdown.Item>Assignments</NavDropdown.Item>
              </LinkContainer>

              <NavDropdown.Divider />

              <LinkContainer to='/export-jobs'>
                <NavDropdown.Item>Export Jobs</NavDropdown.Item>
              </LinkContainer>

              <LinkContainer to='/import-jobs'>
                <NavDropdown.Item>Import Jobs</NavDropdown.Item>
              </LinkContainer>
            </NavDropdown>

            <Can I="manage" a="User">
              <NavDropdown title="Admin">
                <LinkContainer to='/users'>
                  <NavDropdown.Item>Users</NavDropdown.Item>
                </LinkContainer>

                <Can I="manage" a="all">
                  <NavDropdown.Divider />

                  <LinkContainer to='/dynamic-fields'>
                    <NavDropdown.Item>Dynamic Fields</NavDropdown.Item>
                  </LinkContainer>

                  <LinkContainer to='/field_export_profiles'>
                    <NavDropdown.Item>Field Export Profiles</NavDropdown.Item>
                  </LinkContainer>

                  <NavDropdown.Divider />

                  <LinkContainer to='/system_information'>
                    <NavDropdown.Item>System Information</NavDropdown.Item>
                  </LinkContainer>
                </Can>
              </NavDropdown>
            </Can>
          </Nav>

          <Nav>
            <NavDropdown alignRight title={this.props.user.firstName + ' ' + this.props.user.lastName}>
              <LinkContainer to={'/users/' + this.props.user.uid + '/edit'}>
                <NavDropdown.Item>Profile</NavDropdown.Item>
              </LinkContainer>

              <NavDropdown.Divider />

              <NavDropdown.Item onClick={this.signOut}>Sign Out</NavDropdown.Item>
            </NavDropdown>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
    );
  }
}
