import React from 'react'
import { Link } from "react-router-dom";
import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar'

export default class DigitalObjectShow extends React.Component {

  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div>
        <ContextualNavbar lefthandLabel="&laquo; Back to Digital Objects" lefthandLabelLink="/digital-objects">
          <Link to="/digital-objects/:uuid/edit" className="nav-link" href="#">Edit</Link>
        </ContextualNavbar>
      </div>
    )
  }

  componentDidMount() {
    //TODO: load data for digital object
    console.log('Component mounted. uuid: ' + this.props.match.params.uuid);
    //fetchDigitalObject()
  }

  fetchDigitalObject() {

  }
}
