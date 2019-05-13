import React from 'react';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from '../../../util/hyacinth_api';
import withErrorHandler from '../../../hoc/withErrorHandler/withErrorHandler';
import FieldSetForm from './FieldSetForm';

class FieldSetEdit extends React.Component {
  updateFieldSet = (data) => {
    const { params: { projectStringKey, id } } = this.props.match;

    hyacinthApi.patch(`/projects/${projectStringKey}/field_sets/${id}`, data)
      .then((res) => {
        this.props.history.push(`/projects/${projectStringKey}/field_sets/`);
      });
  }

  render() {
    return (
      <>
        <ProjectSubHeading>Edit Field Set</ProjectSubHeading>
        <FieldSetForm submitFormAction={this.updateFieldSet} submitButtonName="Update" />
      </>
    );
  }
}

export default withErrorHandler(FieldSetEdit, hyacinthApi);
