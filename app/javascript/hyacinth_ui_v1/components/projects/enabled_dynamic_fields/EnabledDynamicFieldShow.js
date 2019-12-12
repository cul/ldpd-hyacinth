import React from 'react';
import { startCase } from 'lodash';
import produce from 'immer';

import TabHeading from '../../ui/tabs/TabHeading';
import EnabledDynamicFieldForm from './EnabledDynamicFieldForm';
import { Can } from '../../../util/ability_context';
import EditButton from '../../ui/buttons/EditButton';
import { projects } from '../../../util/hyacinth_api';
import ProjectInterface from '../ProjectInterface';

export default class EnabledDynamicFieldShow extends React.Component {
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
        <TabHeading>
          {`Enabled Dynamic Fields for ${startCase(digitalObjectType)}`}
          <Can I="manage" of={{ subjectType: 'Project', projectStringKey }}>
            <EditButton
              className="float-right"
              size="lg"
              link={`/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}/edit`}
            />
          </Can>
        </TabHeading>

        <EnabledDynamicFieldForm
          formType="show"
          projectStringKey={projectStringKey}
          digitalObjectType={digitalObjectType}
        />
      </ProjectInterface>
    );
  }
}
