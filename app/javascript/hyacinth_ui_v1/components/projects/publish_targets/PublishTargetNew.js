import React from 'react';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import PublishTargetForm from './PublishTargetForm';

class PublishTargetNew extends React.Component {
  createPublishTarget = (data) => {
    hyacinthApi.post(`/projects/${this.props.match.params.string_key}/publish_targets`, data)
      .then((res) => {
        this.props.history.push(`/projects/${this.props.match.params.string_key}/publish_targets/${res.data.publish_target.string_key}/edit`);
      });
  }

  render() {
    return (
      <>
        <ProjectSubHeading>Create New Publish Target</ProjectSubHeading>
        <PublishTargetForm submitFormAction={this.createPublishTarget} submitButtonName="Create" />
      </>
    );
  }
}

export default withErrorHandler(PublishTargetNew, hyacinthApi);
