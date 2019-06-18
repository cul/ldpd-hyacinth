import React from 'react';
import { Link } from 'react-router-dom';

import ContextualNavbar from '../../layout/ContextualNavbar';
import TaskNav from '../../layout/TaskNav';


export default class ItemShow extends React.PureComponent {
  render() {
    console.log(this.props.data);
    const {
      data: {
        uid,
        doi,
        projects,
      },
    } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Item: Really Long Title Goes Here When I Figure Out How Dynamic Fields Work"
        />
        <TaskNav>
          <TaskNav.Link href={`/digital_objects/${uid}/children`}>Manage Child Assets</TaskNav.Link>
          <TaskNav.Link href={`/digital_objects/new?parent=${uid}&digitalObjectType=asset`}>New Child Asset</TaskNav.Link>
          <TaskNav.Link href="/digital_objects/parents">Parents</TaskNav.Link>
          <TaskNav.Link href="/digital_objects/1/rights">Rights</TaskNav.Link>
          <TaskNav.Link href="/assignment/new">Assign This</TaskNav.Link>
          <TaskNav.Link href={`/digital_objects/${uid}/edit`}>Edit</TaskNav.Link>
        </TaskNav>

        <dl className="row">
          <dt className="col-sm-3">Project(s)</dt>
          <dd class="col-sm-9">
            { projects && projects.map(p => <span>{p.displayLabel}</span>) }
          </dd>

          <dt className="col-sm-3">UID</dt>
          <dd className="col-sm-9">{uid}</dd>

          <dt className="col-sm-3">DOI</dt>
          <dd className="col-sm-9">{doi}</dd>

          <dt className="col-sm-3">Child Objects</dt>
          <dd className="col-sm-9"></dd>

          <dt className="col-sm-3">View As</dt>
          <dd className="col-sm-9">
            <a href={`/api/v1/digital_objects/${uid}.json`} target="_blank" rel="noopener noreferrer">JSON</a>
          </dd>

          <dt className="col"></dt>
        </dl>
      </>
    )
  }
}
