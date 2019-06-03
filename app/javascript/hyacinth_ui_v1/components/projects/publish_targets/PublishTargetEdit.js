import React from 'react';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import PublishTargetForm from './PublishTargetForm';

class PublishTargetEdit extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, stringKey } } } = this.props;

    return (
      <>
        <ProjectSubHeading>Edit Publish Target</ProjectSubHeading>
        <PublishTargetForm formType="edit" projectStringKey={projectStringKey} stringKey={stringKey} />
      </>
    );
  }
}

export default PublishTargetEdit;
