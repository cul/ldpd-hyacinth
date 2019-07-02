import React from 'react';
import { startCase } from 'lodash';

import TabHeading from '../../ui/tabs/TabHeading';
import EnabledDynamicFieldForm from './EnabledDynamicFieldForm';

export default class EnabledDynamicFieldsEdit extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, digitalObjectType } } } = this.props;

    return (
      <>
        <TabHeading>{`Edit Enabled Dynamic Fields for ${startCase(digitalObjectType)}`}</TabHeading>
        <EnabledDynamicFieldForm
          formType="edit"
          projectStringKey={projectStringKey}
          digitalObjectType={digitalObjectType}
        />
      </>
    );
  }
}
