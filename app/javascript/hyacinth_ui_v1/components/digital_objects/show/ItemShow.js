import React from 'react';
import { Link } from 'react-router-dom';

import ContextualNavbar from '../../layout/ContextualNavbar';
import TaskNav from '../../layout/TaskNav';
import DigitalObjectSummary from '../DigitalObjectSummary';
import DynamicFieldDataForm from '../DynamicFieldDataForm';

export default class ItemShow extends React.PureComponent {
  render() {
    const {
      data,
      data: {
        uid,
        projects,
        digitalObjectType,
      },
    } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Item | Really Long Title Goes Here When I Figure Out How Dynamic Fields Work"
        />

        <DigitalObjectSummary
          data={data}
        />
        <TaskNav>
          <TaskNav.Link href={`/digital_objects/${uid}/children`}>Manage Child Assets</TaskNav.Link>
          <TaskNav.Link href={`/digital_objects/new?parent=${uid}&digitalObjectType=asset`}>New Child Asset</TaskNav.Link>
          <TaskNav.Link href={`/digital_objects/${uid}/parents`}>Parents</TaskNav.Link>
          <TaskNav.Link href={`/digital_objects/${uid}/rights`}>Rights</TaskNav.Link>
          <TaskNav.Link href="/assignment/new">Assign This</TaskNav.Link>
          <TaskNav.Link href={`/digital_objects/${uid}/edit`}>Edit</TaskNav.Link>
        </TaskNav>

        <hr />

        <DynamicFieldDataForm
          projects={projects}
          digitalObjectType={digitalObjectType}
        />
      </>
    )
  }
}
