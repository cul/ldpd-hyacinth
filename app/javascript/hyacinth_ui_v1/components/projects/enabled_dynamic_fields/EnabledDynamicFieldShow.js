import React from 'react';
import { startCase } from 'lodash';

import TabHeading from '../../ui/tabs/TabHeading';
import EnabledDynamicFieldForm from './EnabledDynamicFieldForm';
import { Can } from '../../../util/ability_context';
import EditButton from '../../ui/buttons/EditButton';

export default class EnabledDynamicFieldShow extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, digitalObjectType } } } = this.props;

    return (
      <>
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
      </>
    );
  }
}
