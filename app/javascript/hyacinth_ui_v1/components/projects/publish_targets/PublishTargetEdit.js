import React from 'react';

import TabHeading from '../../ui/tabs/TabHeading';
import PublishTargetForm from './PublishTargetForm';

class PublishTargetEdit extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, stringKey } } } = this.props;

    return (
      <>
        <TabHeading>Edit Publish Target</TabHeading>
        <PublishTargetForm formType="edit" projectStringKey={projectStringKey} stringKey={stringKey} />
      </>
    );
  }
}

export default PublishTargetEdit;
