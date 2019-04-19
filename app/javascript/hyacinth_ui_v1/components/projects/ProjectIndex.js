import React from 'react';
import { Link } from "react-router-dom";
import { Table } from "react-bootstrap";
import producer from "immer";

import ContextualNavbar from 'hyacinth_ui_v1/components/layout/ContextualNavbar';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';

export default class ProjectIndex extends React.Component {
  state = {
    projects: []
  }

  componentDidMount() {
    hyacinthApi.get('/projects/')
      .then(res => {
        this.setState(producer(draft => { draft.projects = res.data.projects }))
      }); // TODO: catch error
  }

  render() {

    let rows = this.state.projects.map(project => {
      return (
        <tr key={project.id}>
          <td><Link to={"/projects/" + project.string_key + "/core_data"} className="nav-link" href="#">{project.display_label}</Link></td>
          <td>{project.string_key}</td>
          <td></td>
        </tr>
      )
    })

    return(
      <div>
        <ContextualNavbar
          title="Projects"
          rightHandLinks={[{link: '/projects/new', label: 'New Project'}]} />

        <Table striped>
          <thead>
            <tr>
              <th>Display Label</th>
              <th>String Key</th>
              <th>Download Template Header</th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </Table>
      </div>
    )
  }
}
