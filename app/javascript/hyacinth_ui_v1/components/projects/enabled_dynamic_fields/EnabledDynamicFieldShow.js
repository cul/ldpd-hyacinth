import React from 'react';
import { Link } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { startCase } from 'lodash';

import TabHeading from '../../ui/tabs/TabHeading';
import EnabledDynamicFieldForm from './EnabledDynamicFieldForm';
import { Can } from '../../../util/ability_context';

export default class EnabledDynamicFieldShow extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, digitalObjectType } } } = this.props;

    return (
      <>
        <TabHeading>
          {`Enabled Dynamic Fields for ${startCase(digitalObjectType)}`}
          {'  '}
          <Can I="manage" of={{ subjectType: 'Project', projectStringKey }}>
            <Link to={`/projects/${projectStringKey}/enabled_dynamic_fields/${digitalObjectType}/edit`}>
              <FontAwesomeIcon icon="pen" />
            </Link>
          </Can>
        </TabHeading>

        <EnabledDynamicFieldForm
          formType="show"
          projectStringKey={projectStringKey}
          digitalObjectType={digitalObjectType}
        />
      </>
    );
  }
}
