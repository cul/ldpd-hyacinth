import React from 'react';
import PropTypes from 'prop-types';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import PublishTargetForm from './PublishTargetForm';

const propTypes = {
  history: PropTypes.object.isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      projectStringKey: PropTypes.string,
    }).isRequired,
  }).isRequired,
};

class PublishTargetNew extends React.Component {
  createPublishTarget = (data) => {
    const {
      history,
      match: {
        params: { projectStringKey },
      },
    } = this.props;

    hyacinthApi.post(`/projects/${projectStringKey}/publish_targets`, data)
      .then((res) => {
        const { publishTarget: { stringKey } } = res.data;

        history.push(`/projects/${projectStringKey}/publish_targets/${stringKey}/edit`);
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

PublishTargetNew.propTypes = propTypes;

export default withErrorHandler(PublishTargetNew, hyacinthApi);
