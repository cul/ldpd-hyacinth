import React from 'react';
import { startCase } from 'lodash';
import produce from 'immer';

import TabHeading from '../../shared/tabs/TabHeading';
import PublishTargetsForm from './PublishTargetsForm';
import { Can } from '../../../utils/abilityContext';
import EditButton from '../../shared/buttons/EditButton';
import { projects } from '../../../utils/hyacinthApi';
import ProjectInterface from '../ProjectInterface';

export default class PublishTargetsFormShow extends React.Component {
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
        <TabHeading>
          Enabled Publish Targets
          <Can I="update" of={{ subjectType: 'Project', stringKey: projectStringKey }}>
            <EditButton
              className="float-end"
              size="lg"
              aria-label="Edit"
              link={`/projects/${projectStringKey}/publish_targets/edit`}
            />
          </Can>
        </TabHeading>

        <PublishTargetsForm
          readOnly
          projectStringKey={projectStringKey}
        />
      </ProjectInterface>
    );
  }
}
