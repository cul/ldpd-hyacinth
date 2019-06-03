import React from 'react';
import { Link } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { startCase } from 'lodash';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import EnabledDynamicFieldForm from './EnabledDynamicFieldForm';
import { Can } from '../../../util/ability_context';

export default class EnabledDynamicFieldShow extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, digitalObjectType } } } = this.props;

    return (
      <>
        <ProjectSubHeading>
          {`Enabled Dynamic Fields for ${startCase(digitalObjectType)}`}
          {'  '}
          <Can I="manage" of={{ subjectType: 'Project', projectStringKey }}>
            <Link to={`/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}/edit`}>
              <FontAwesomeIcon icon="pen" />
            </Link>
          </Can>
        </ProjectSubHeading>

        <EnabledDynamicFieldForm
          formType="show"
          projectStringKey={projectStringKey}
          digitalObjectType={digitalObjectType}
        />
      </>
    );
  }
}
