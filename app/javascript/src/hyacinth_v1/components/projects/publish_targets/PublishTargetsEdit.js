import React from 'react';
import { startCase } from 'lodash';
import produce from 'immer';

import TabHeading from '../../shared/tabs/TabHeading';
import { PublishTargetsForm } from './PublishTargetsForm';
import { projects } from '../../../utils/hyacinthApi';
import ProjectInterface from '../ProjectInterface';

export default class PublishTargetsEdit extends React.Component {
  state = {
    project: {},
  }

  componentDidMount() {
    const { match: { params: { projectStringKey } } } = this.props;

    projects.get(projectStringKey)
      .then((res) => {
        const { project } = res.data;

        this.setState(produce((draft) => {
          draft.project = project;
        }));
      });
  }

  render() {
    const { match: { params: { projectStringKey } } } = this.props;

    return (
      <ProjectInterface project={this.state.project}>
        <TabHeading>Edit Enabled Publish Targets</TabHeading>
        <PublishTargetsForm
          projectStringKey={projectStringKey}
        />
      </ProjectInterface>
    );
  }
}
