import React from 'react';
import produce from 'immer';

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';
import PublishTargetForm from './PublishTargetForm';
import withErrorHandler from 'hyacinth_ui_v1/hoc/withErrorHandler/withErrorHandler';

class PublishTargetEdit extends React.Component {
  updatePublishTarget = (data) => {
    hyacinthApi.patch(this.props.match.url.replace('edit', ''), data)
      .then(res => {
        this.props.history.push(`/projects/${this.props.match.params.string_key}/publish_targets/`);
      });
  }

  render() {
    return(
      <>
        <ProjectSubHeading>Edit Publish Target</ProjectSubHeading>
        <PublishTargetForm submitFormAction={this.updatePublishTarget} submitButtonName="Update"/>
      </>
    )
  }
}

export default withErrorHandler(PublishTargetEdit, hyacinthApi)
