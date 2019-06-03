import React from 'react';
import { Link } from 'react-router-dom';
import { Table } from 'react-bootstrap';
import produce from 'immer';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import { Can } from '../../util/ability_context';

export default class ProjectIndex extends React.Component {
  state = {
    projects: [],
  }

  componentDidMount() {
    hyacinthApi.get('/projects/')
      .then((res) => {
        this.setState(produce((draft) => { draft.projects = res.data.projects; }));
      });
  }

  render() {
    const { projects } = this.state;

    return (
      <>
        <Can I="create" a="Project" passThrough>
          {
            can => (
              <ContextualNavbar
                title="Projects"
                rightHandLinks={can ? [{ link: '/projects/new', label: 'New Project' }] : []}
              />
            )
          }
        </Can>

        <Table hover>
          <thead>
            <tr>
              <th>Display Label</th>
              <th>String Key</th>
              <th>Download Template Header</th>
            </tr>
          </thead>
          <tbody>
            {
              projects && (
                projects.map(project => (
                  <tr key={project.id}>
                    <td><Link to={`/projects/${project.stringKey}/core_data`}>{project.displayLabel}</Link></td>
                    <td>{project.stringKey}</td>
                    <td />
                  </tr>
                ))
              )
            }
          </tbody>
        </Table>
      </>
    );
  }
}
