import React from 'react';
import { startCase } from 'lodash';
import produce from 'immer';

import TabHeading from '../../shared/tabs/TabHeading';
import { Can } from '../../../utils/abilityContext';
import EditButton from '../../shared/buttons/EditButton';
import { projects } from '../../../utils/hyacinthApi';
import ProjectInterface from '../ProjectInterface';
import EnabledDynamicFieldForm from './enabled_dynamic_field_form/EnabledDynamicFieldForm';

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
          <Can I="update" of={{ subjectType: 'Project', stringKey: projectStringKey }}>
            <EditButton
              className="float-end"
              size="lg"
              aria-label="Edit"
              link={`/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}/edit`}
            />
          </Can>
        </TabHeading>
        <EnabledDynamicFieldForm
          readOnly
          projectStringKey={projectStringKey}
          digitalObjectType={digitalObjectType}
        />
      </ProjectInterface>
    );
  }
}
