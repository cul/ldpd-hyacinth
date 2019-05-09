import React from 'react';
import produce from 'immer';

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';
import withErrorHandler from 'hyacinth_ui_v1/hoc/withErrorHandler/withErrorHandler';
import PublishTargetForm from './PublishTargetForm';

class PublishTargetNew extends React.Component {
  createPublishTarget = (data) => {
    hyacinthApi.post(`/projects/${this.props.match.params.string_key}/publish_targets`, data)
      .then((res) => {
        console.log('Publish Target Created');
        // redirect to edit screen for that user
        console.log(res);
        this.props.history.push(`/projects/${this.props.match.params.string_key}/publish_targets/${res.data.publish_target.string_key}/edit`);
      })
      .catch((error) => {
        console.log(error);
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
