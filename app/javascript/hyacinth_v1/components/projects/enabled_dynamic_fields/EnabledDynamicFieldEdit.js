import React from 'react';
import { startCase } from 'lodash';
import produce from 'immer';

import TabHeading from '../../shared/tabs/TabHeading';
import { EnabledDynamicFieldForm } from './EnabledDynamicFieldForm';
import { projects } from '../../../utils/hyacinthApi';
import ProjectInterface from '../ProjectInterface';

export default class EnabledDynamicFieldsEdit extends React.Component {
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
    const { match: { params: { projectStringKey, digitalObjectType } } } = this.props;

    return (
      <ProjectInterface project={this.state.project} key={digitalObjectType}>
        <TabHeading>{`Edit Enabled Dynamic Fields for ${startCase(digitalObjectType)}`}</TabHeading>
        <EnabledDynamicFieldForm
          projectStringKey={projectStringKey}
          digitalObjectType={digitalObjectType}
        />
      </ProjectInterface>
    );
  }
}
