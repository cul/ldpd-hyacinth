import React from 'react';
import PropTypes from 'prop-types';

import TabHeading from '../../ui/tabs/TabHeading';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import PublishTargetForm from './PublishTargetForm';

class PublishTargetNew extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, stringKey } } } = this.props;
    return (
      <>
        <TabHeading>Create New Publish Target</TabHeading>
        <PublishTargetForm formType="new" projectStringKey={projectStringKey} stringKey={stringKey} />
      </>
    );
  }
}

PublishTargetNew.propTypes = {
  history: PropTypes.object.isRequired,
  match: PropTypes.shape({
    params: PropTypes.shape({
      projectStringKey: PropTypes.string,
    }).isRequired,
  }).isRequired,
};

export default PublishTargetNew;
