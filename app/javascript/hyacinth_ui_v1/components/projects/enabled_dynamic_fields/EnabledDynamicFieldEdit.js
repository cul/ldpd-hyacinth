import React from 'react';
import { startCase } from 'lodash';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import EnabledDynamicFieldForm from './EnabledDynamicFieldForm';

export default class EnabledDynamicFieldsEdit extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, digitalObjectType } } } = this.props;

    return (
      <>
        <ProjectSubHeading>{`Edit Enabled Dynamic Fields for ${startCase(digitalObjectType)}`}</ProjectSubHeading>
        <EnabledDynamicFieldForm
          formType="edit"
          projectStringKey={projectStringKey}
          digitalObjectType={digitalObjectType}
        />
      </>
    );
  }
}
