import React from 'react'
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import Constants from 'hyacinth_ui_v1/Constants'
import NavItemDropdown from 'hyacinth_ui_v1/components/layout/NavItemDropdown'

export default class TopNavbar extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      show: this.props.show
    };

    // bind functions that should always run in the context of this instance
    this.toggle = this.toggle.bind(this);
    this.signOut = this.signOut.bind(this);
  }

  render() {
    return(
      <nav id="top-navbar" className="navbar navbar-expand-md navbar-dark bg-dark">
        <a className="navbar-brand" href="/">Hyacinth</a>
        <button onClick={this.toggle} className="navbar-toggler" type="button">
          <span className="navbar-toggler-icon"></span>
        </button>

        <div className={'collapse navbar-collapse ' + (this.state.show ? 'show' : '')}>
          <ul className="navbar-nav mr-auto">
            <li className="nav-item">
              <Link to="/digital-objects" className="nav-link">Digital Objects</Link>
            </li>

            <NavItemDropdown label="Manage">
              <Link to="/assignments" className="dropdown-item">Assignments</Link>
              <Link to="/controlled-vocabularies" className="dropdown-item">Controlled Vocabularies</Link>
              <Link to="/export-jobs" className="dropdown-item">Export Jobs</Link>
              <Link to="/import-jobs" className="dropdown-item">Import Jobs</Link>
              <Link to="/projects" className="dropdown-item">Projects</Link>
            </NavItemDropdown>

            <NavItemDropdown label="Admin">
              <Link to="/dynamic-fields" className="dropdown-item">Dynamic Fields</Link>
              <Link to="/groups" className="dropdown-item">Groups</Link>
              <Link to="/role-permissions" className="dropdown-item">Role Permissions</Link>
              <Link to="/users" className="dropdown-item">Users</Link>
            </NavItemDropdown>
          </ul>

          <ul className="navbar-nav">
            <NavItemDropdown label={<span>0 <FontAwesomeIcon icon="bell" /></span>} dropdownDirection="right">
              <Link to="/notifications/1" className="dropdown-item">Notification 1</Link>
              <Link to="/notifications/2" className="dropdown-item">Notification 2</Link>
            </NavItemDropdown>

            <NavItemDropdown label="Username" dropdownDirection="right">
              <Link to="/dashboard" className="dropdown-item">Dashboard</Link>
              <Link to="/settings" className="dropdown-item">Settings</Link>
              <div className="dropdown-divider"></div>
              <a onClick={this.signOut} href="#" className="dropdown-item">Sign Out</a>
            </NavItemDropdown>
          </ul>
        </div>
      </nav>
    );
  }

  toggle(e) {
    e.preventDefault(); // prevent hashchange when visibility is toggled
    this.setState((state, props) => {
      return {show: !state.show};
    });
  }

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
}
