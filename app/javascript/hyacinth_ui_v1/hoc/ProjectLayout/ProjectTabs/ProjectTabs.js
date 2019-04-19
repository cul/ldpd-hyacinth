import React from 'react'
import { Link } from "react-router-dom";
import { Nav, Navbar, Button } from "react-bootstrap";
import { LinkContainer } from "react-router-bootstrap";

export default class ProjectTabs extends React.Component {

  render() {
    return (
      <Nav fill variant="tabs" className="mb-2">
        {this.props.children}
      </Nav>
    )
  }
}
