import React from 'react'
import { Nav } from "react-bootstrap";
import { LinkContainer } from "react-router-bootstrap";
import { Route } from "react-router-dom";

export default class ProjectTab extends React.Component {

  render() {
    return (
       <Route
         {...this.props}
         children={({ location, match }) => {
           return (
             <Nav.Item key={this.props.name}>
               <LinkContainer activeClassName="active" {...this.props}>
                 <Nav.Link eventKey={this.props.name}>
                   {this.props.name}
                 </Nav.Link>
               </LinkContainer>
             </Nav.Item>
           )
         }}
       />
    )
  }
}
