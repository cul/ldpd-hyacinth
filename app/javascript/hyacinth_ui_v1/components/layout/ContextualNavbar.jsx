import React from 'react'
import { Link } from "react-router-dom";

export default class ContextualNavbar extends React.Component {

  constructor(props) {
    super(props);
  }

  renderLefthandLabel() {
    //if a link has been provided, lefthand label should be a link
    if(this.props.lefthandLabelLink) {
      return (<Link to={this.props.lefthandLabelLink} className="navbar-brand">{this.props.lefthandLabel}</Link>);
    } else {
      return (<span className="navbar-brand">{this.props.lefthandLabel}</span>);
    }
  }

  render() {
    return(
      <nav className="navbar navbar-expand-lg navbar-dark bg-dark" style={{margin:'1em 0'}}>
        {this.renderLefthandLabel()}
        <ul className="navbar-nav ml-auto">
          <li className="nav-item">
            {this.props.children}
          </li>
        </ul>
      </nav>
    )
  }
}
